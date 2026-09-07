import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { enterValue, getValue } from "../../support-functions/html-behaviour";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { ElementKey } from "../../../env/global";

// Generates a disposable, collision-free product name/SKU (same "qa-<ts>"
// shape as form.ts's "unique value" step) and stashes it in globalVariables
// so a later step in the same scenario can confirm the exact value it typed
// really persisted, rather than just trusting a save succeeded - mirrors
// checkout.ts's guest-email stash/reuse pair.
When(/^I fill in the "([^"]*)" input field with a unique product name$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const productName = `Velstar Test Product ${Date.now()}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await enterValue(page, elementIdentifier, productName);

    this.globalVariables["product name"] = productName;
});

When(/^I fill in the "([^"]*)" input field with a unique product SKU$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const productSku = `VEL-TEST-${Date.now()}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await enterValue(page, elementIdentifier, productSku);

    this.globalVariables["product sku"] = productSku;
});

Then(/^the "([^"]*)" input field should have the stored product name$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const productName = this.globalVariables["product name"];
    if (!productName) {
        throw new Error(`No stored product name found - "I fill in the ... with a unique product name" must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await waitFor(async () => (await getValue(page, elementIdentifier)) === productName, {
        expected: `"${elementKey}" (${elementIdentifier}) to have the stored product name "${productName}"`,
        describeActual: async () => `value was "${(await getValue(page, elementIdentifier).catch(() => null)) ?? "(could not read value)"}"`,
    });
});

Then(/^the "([^"]*)" input field should have the stored product SKU$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const productSku = this.globalVariables["product sku"];
    if (!productSku) {
        throw new Error(`No stored product SKU found - "I fill in the ... with a unique product SKU" must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await waitFor(async () => (await getValue(page, elementIdentifier)) === productSku, {
        expected: `"${elementKey}" (${elementIdentifier}) to have the stored product SKU "${productSku}"`,
        describeActual: async () => `value was "${(await getValue(page, elementIdentifier).catch(() => null)) ?? "(could not read value)"}"`,
    });
});
