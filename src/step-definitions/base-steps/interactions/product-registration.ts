import { Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { enterValue } from "../../support-functions/html-behaviour";
import { waitFor } from "../../support-functions/wait-for-behaviour";

type RegistrationData = {
    firstName: string;
    lastName: string;
    email: string;
    placeOfPurchase: string;
    serialNumber: string;
};

const REGISTRATION_FIELDS = ["firstName", "lastName", "email", "placeOfPurchase", "serialNumber"] as const;
type RegistrationField = typeof REGISTRATION_FIELDS[number];

const FIELD_TO_ELEMENT_KEY: Record<RegistrationField, string> = {
    firstName: "registration first name input",
    lastName: "registration last name input",
    email: "registration email input",
    placeOfPurchase: "registration place of purchase input",
    serialNumber: "registration serial number input",
};

const generateRegistration = (omit?: RegistrationField): RegistrationData => {
    const stamp = Date.now();
    return {
        firstName: "Velstar",
        lastName: `Warranty${stamp}`,
        email: `registration.qa.${stamp}@velstar.co.uk`,
        placeOfPurchase: omit === "placeOfPurchase" ? "" : "Velstar Test Store",
        serialNumber: omit === "serialNumber" ? "" : `SN${stamp}`,
    };
};

// Fills every field of the product registration form (generating a fresh,
// unique identity each time so the record is greppable and collision-free -
// see "the warranty lookup ..." steps below, which look this exact record
// back up by lastName + serialNumber) and remembers the whole record as
// JSON for later reuse. Picks a fixed "Standard 460"/"DIY" product/installer
// combination and today's date - this project's registration flow doesn't
// need those to vary per test, only the identity fields the warranty finder
// later looks up.
const fillRegistrationForm = async (world: ScenarioWorld, omit?: RegistrationField): Promise<RegistrationData> => {
    const { screen: { page }, globalConfig } = world;
    const data = generateRegistration(omit);

    for (const field of REGISTRATION_FIELDS) {
        if (field === omit) continue;
        const elementIdentifier = getElementLocator(page, FIELD_TO_ELEMENT_KEY[field], globalConfig);
        await page.waitForSelector(elementIdentifier, { timeout: 15000 });
        await enterValue(page, elementIdentifier, data[field]);
    }

    const dateButtonSelector = getElementLocator(page, "registration date of purchase button", globalConfig);
    await page.click(dateButtonSelector);
    const today = new Date().getDate();
    await page.getByRole("gridcell", { name: String(today), exact: true }).first().click();

    const modelComboboxSelector = getElementLocator(page, "registration product model combobox", globalConfig);
    const modelOptionSelector = getElementLocator(page, "Standard 460 model option", globalConfig);
    await page.click(modelComboboxSelector);
    await page.click(modelOptionSelector);

    // The visible Radix listbox only exposes each option's TRANSLATED label,
    // but the underlying native <select> this component syncs from keeps a
    // stable, locale-invariant `value` per option - reading the label for
    // the known value from that hidden select, then clicking the portalled
    // role=option with that label, is what makes this work on any locale
    // without hardcoding translated text.
    const installedBySelectSelector = getElementLocator(page, "registration installed by select", globalConfig);
    const installedByComboboxSelector = getElementLocator(page, "registration installed by combobox", globalConfig);
    const installedByLabel = await page.locator(installedBySelectSelector).locator('option[value="DIY"]').textContent();
    await page.click(installedByComboboxSelector);
    await page.getByRole("option", { name: installedByLabel ?? "DIY", exact: true }).click();

    return data;
};

When(/^I fill in a freshly generated product registration, remembering it as "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string) {
    const data = await fillRegistrationForm(this);
    this.globalVariables[variableName] = JSON.stringify(data);
});

When(/^I fill in a freshly generated product registration except "(firstName|lastName|email|placeOfPurchase|serialNumber)", remembering it as "([^"]*)"$/, async function (this: ScenarioWorld, fieldToOmit: RegistrationField, variableName: string) {
    const data = await fillRegistrationForm(this, fieldToOmit);
    this.globalVariables[variableName] = JSON.stringify(data);
});

// Fills and submits the warranty finder using the lastName/serialNumber
// from a registration remembered earlier by the steps above.
When(/^I look up the warranty using the remembered product registration "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const stored = this.globalVariables[variableName];
    if (!stored) {
        throw new Error(`No remembered product registration found for "${variableName}" - fill in a registration first.`);
    }
    const registration = JSON.parse(stored) as RegistrationData;

    const lastNameSelector = getElementLocator(page, "warranty last name input", globalConfig);
    const serialNumberSelector = getElementLocator(page, "warranty serial number input", globalConfig);
    const submitSelector = getElementLocator(page, "warranty submit button", globalConfig);

    await enterValue(page, lastNameSelector, registration.lastName);
    await enterValue(page, serialNumberSelector, registration.serialNumber);
    await waitFor(() => page.isEnabled(submitSelector));
    await page.click(submitSelector);
});

Then(/^the warranty lookup should succeed for "([^"]*)" using the remembered registration "([^"]*)"$/, async function (this: ScenarioWorld, productName: string, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const stored = this.globalVariables[variableName];
    if (!stored) {
        throw new Error(`No remembered product registration found for "${variableName}".`);
    }
    const registration = JSON.parse(stored) as RegistrationData;

    const resultSelector = getElementLocator(page, "warranty success result", globalConfig);
    await expect(page.locator(resultSelector)).toContainText("Registered on", { timeout: 15000 });
    await expect(page.locator(resultSelector)).toContainText(productName);
    await expect(page.locator(resultSelector)).toContainText(registration.serialNumber);
});
