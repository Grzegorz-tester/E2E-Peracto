import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { parsePrice } from "../../support-functions/price-helper";

// For carrying a price from one page to a later one when the two pages
// format it differently - confirmed live on Andy Thornton's checkout
// (2026-09-30): the review step's summary reads "£144.00(inc VAT)" while the
// thank-you page reads "£144.00", so a plain text comparison can't work, and
// the amount itself depends on the delivery address so it can't be
// hard-coded either. Compares the parsed numbers, so it's format-agnostic
// across storefronts (see price-helper.ts).
When(/^I remember the price in "([^"]*)" as "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const text = await page.textContent(elementIdentifier, { timeout: 15000 });
    this.globalVariables[variableName] = String(parsePrice(text));
});

Then(/^the price in "([^"]*)" should equal the remembered "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
        throw new Error(`No remembered price found for "${variableName}" - "I remember the price in ... as ..." must run first.`);
    }
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    let lastText: string | null = null;

    await waitFor(async () => {
        lastText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
        if (!lastText) return false;
        return Math.abs(parsePrice(lastText) - Number(remembered)) < 0.005;
    }, {
        expected: `"${elementKey}" (${elementIdentifier}) to show the remembered price ${Number(remembered).toFixed(2)}`,
        describeActual: async () => `text was "${lastText?.trim() ?? "(could not read text)"}"`,
    });
});

// For an action that should add a known amount to a running total (e.g.
// ticking a paid service in the basket) - both the starting total and the
// amount being added are read live and remembered beforehand, so nothing
// about the catalog's prices is hard-coded. Polls, since the total only
// updates once the basket round-trip completes.
Then(/^the price in "([^"]*)" should equal the remembered "([^"]*)" plus the remembered "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, baseVariable: string, addedVariable: string) {
    const { screen: { page }, globalConfig } = this;
    const base = this.globalVariables[baseVariable];
    const added = this.globalVariables[addedVariable];
    if (base === undefined || added === undefined) {
        throw new Error(`No remembered price found for "${base === undefined ? baseVariable : addedVariable}" - "I remember the price in ... as ..." must run first.`);
    }
    const expected = Number(base) + Number(added);
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    let lastText: string | null = null;

    await waitFor(async () => {
        lastText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
        if (!lastText) return false;
        return Math.abs(parsePrice(lastText) - expected) < 0.005;
    }, {
        expected: `"${elementKey}" (${elementIdentifier}) to show ${Number(base).toFixed(2)} + ${Number(added).toFixed(2)} = ${expected.toFixed(2)}`,
        describeActual: async () => `text was "${lastText?.trim() ?? "(could not read text)"}"`,
    });
});

// For a quantity change - the line/subtotal should become the remembered
// unit price times the new quantity. Keeps the unit price itself out of the
// feature file: confirmed live on HIB staging (2026-10-13) that the Vanquish
// Bathroom Cabinet moved from £749.00 to £779.00, which broke every
// hard-coded expectation without anything actually being wrong.
Then(/^the price in "([^"]*)" should equal the remembered "([^"]*)" times (\d+)$/, async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string, multiplier: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
        throw new Error(`No remembered price found for "${variableName}" - "I remember the price in ... as ..." must run first.`);
    }
    const expected = Number(remembered) * Number(multiplier);
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    let lastText: string | null = null;

    await waitFor(async () => {
        lastText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
        if (!lastText) return false;
        return Math.abs(parsePrice(lastText) - expected) < 0.005;
    }, {
        expected: `"${elementKey}" (${elementIdentifier}) to show ${Number(remembered).toFixed(2)} x ${multiplier} = ${expected.toFixed(2)}`,
        describeActual: async () => `text was "${lastText?.trim() ?? "(could not read text)"}"`,
    });
});
