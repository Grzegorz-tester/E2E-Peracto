import { DataTable, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// Delivery and billing addresses share the exact same underlying form and
// list markup, only distinguished by a "delivery"/"billing" testid prefix.
// Position-numbered add/edit/delete/name selectors are inherently dynamic
// (parametrized by both type and a runtime-determined index), so they're
// computed here rather than as static config - the FORM FIELDS themselves
// are static per page, so those are resolved via elementKey/config like
// every other step, not hardcoded.
const addButtonSelector = (type: string) => `[data-testid="address-book-${type}__add-address-button"]`;
const namesListSelector = (type: string) => `[data-testid^="address-book-${type}__address-"][data-testid$="__name"]`;
const nameSelector = (type: string, n: number) => `[data-testid="address-book-${type}__address-${n}__name"]`;
const editButtonSelector = (type: string, n: number) => `[data-testid="address-book-${type}__address-${n}__edit-address-button"]`;
const deleteButtonSelector = (type: string, n: number) => `[data-testid="address-book-${type}__address-${n}__delete-address-button"]`;
const deleteConfirmSelector = (type: string, n: number) => `[data-testid="address-book-${type}__address-${n}__delete-address-yes-button"]`;

const fillAddressForm = async (
    page: ScenarioWorld["screen"]["page"],
    globalConfig: ScenarioWorld["globalConfig"],
    row: Record<string, string>
) => {
    await page.fill(getElementLocator(page, "address first name", globalConfig), row["First name"]);
    await page.fill(getElementLocator(page, "address last name", globalConfig), row["Last name"]);
    await page.fill(getElementLocator(page, "address line 1", globalConfig), row["Address line 1"]);
    await page.fill(getElementLocator(page, "address city", globalConfig), row["City"]);
    await page.fill(getElementLocator(page, "address postcode", globalConfig), row["Postcode"]);
    await page.click(getElementLocator(page, "Save address", globalConfig));
};

When(/^I add a new (delivery|billing) address with the following details:$/, async function (this: ScenarioWorld, type: string, table: DataTable) {
    const { screen: { page }, globalConfig } = this;
    const row = table.rowsHash();

    const countBefore = await page.locator(namesListSelector(type)).count();

    const addButton = page.locator(addButtonSelector(type));
    if (await addButton.count() > 0) {
        await addButton.click();
        await page.waitForSelector(getElementLocator(page, "address first name", globalConfig), { state: "visible", timeout: 35000 });
    }

    await fillAddressForm(page, globalConfig, row);

    // Different projects on this framework number saved addresses starting
    // from 0 or from 1 (confirmed live: this exact site does 0, a sibling
    // project does 1) - rather than assume either, wait for the list to
    // genuinely grow by one, then read back whichever index actually
    // appeared, from the real testid.
    await waitFor(async () => (await page.locator(namesListSelector(type)).count()) > countBefore, { timeout: 35000, wait: 500 });
    const testids = await page.locator(namesListSelector(type)).evaluateAll((els) => els.map((el) => el.getAttribute("data-testid") ?? ""));
    const indices = testids
        .map((testid) => Number(testid.match(/__address-(\d+)__name$/)?.[1]))
        .filter((n) => !Number.isNaN(n));
    if (indices.length === 0) {
        throw new Error(`Could not determine the new ${type} address's index from testids: ${testids.join(", ")}`);
    }
    const newAddressNumber = Math.max(...indices);

    this.globalVariables[`last added ${type} address number`] = String(newAddressNumber);
});

When(/^I edit the last added (delivery|billing) address with the following details:$/, async function (this: ScenarioWorld, type: string, table: DataTable) {
    const { screen: { page }, globalConfig } = this;
    const row = table.rowsHash();
    const addressNumber = Number(this.globalVariables[`last added ${type} address number`]);

    await page.click(editButtonSelector(type, addressNumber));
    await page.waitForSelector(getElementLocator(page, "address first name", globalConfig), { state: "visible", timeout: 35000 });
    await fillAddressForm(page, globalConfig, row);

    await page.waitForFunction(
        ([selector, expected]) => document.querySelector(selector)?.textContent?.includes(expected as string),
        [nameSelector(type, addressNumber), `${row["First name"]} ${row["Last name"]}`] as const,
        { timeout: 35000 }
    );
});

When(/^I remove the last added (delivery|billing) address$/, async function (this: ScenarioWorld, type: string) {
    const { screen: { page } } = this;
    const addressNumber = Number(this.globalVariables[`last added ${type} address number`]);

    await page.click(deleteButtonSelector(type, addressNumber));
    await page.waitForSelector(deleteConfirmSelector(type, addressNumber), { state: "visible", timeout: 15000 });
    await page.click(deleteConfirmSelector(type, addressNumber));

    await page.waitForSelector(nameSelector(type, addressNumber), { state: "detached", timeout: 35000 });
});
