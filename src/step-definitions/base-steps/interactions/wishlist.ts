import { Given, Then } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// A wishlist list (e.g. Russells' /account/wishlists) is real, shared,
// persistent backend state tied to whichever account runs this suite - an
// earlier failed run can leave test-created rows behind, which then breaks
// a LATER run's own row-count-dependent assertions (e.g. a sort-order
// check). Two independent safety guards prevent this from ever deleting the
// WRONG row: (1) actively wait for every visible row to actually match the
// search filter before trusting the list at all (the app's own debounced
// filtering can lag behind the fill()), and (2) a per-row check that
// refuses to delete anything not containing namePrefix, so a search filter
// that silently didn't apply can never cause a real, non-test row to be
// deleted. namePrefix should be a value only ever used by this suite's own
// created rows (e.g. "Playwright QA"), never a generic/short string.
// Reusable by any project with a similar named-list-with-delete shape -
// elementKey mappings for "Wishlist search input"/"Wishlist rows"/"Confirm
// deletion proceed" belong in that project's own page mapping.
Given(/^I clean up any leftover "([^"]*)" wishlists$/, { timeout: 60000 }, async function (this: ScenarioWorld, namePrefix: string) {
    const { screen: { page }, globalConfig } = this;
    const searchInputSelector = getElementLocator(page, "Wishlist search input", globalConfig);
    const rowsSelector = getElementLocator(page, "Wishlist rows", globalConfig);
    const confirmSelector = getElementLocator(page, "Confirm deletion proceed", globalConfig);

    await page.fill(searchInputSelector, namePrefix);

    await waitFor(async () => {
        const rowTexts = await page.locator(rowsSelector).allTextContents();
        return rowTexts.every((text) => text.includes(namePrefix) || text.includes("No results found."));
    }, {
        timeout: 10000,
        expected: `every visible "Wishlist rows" (${rowsSelector}) row to match the search filter "${namePrefix}" (or show "No results found.")`,
    });

    // A no-matches search renders a single "No results found." placeholder
    // row - filtering it out distinguishes an actual row to delete from
    // that empty state.
    while (await page.locator(rowsSelector).filter({ hasNotText: "No results found." }).count() > 0) {
        const row = page.locator(rowsSelector).filter({ hasNotText: "No results found." }).first();
        const name = (await row.locator("td").first().textContent())?.trim() ?? "";
        if (!name.includes(namePrefix)) {
            throw new Error(`Refusing to delete unexpected wishlist "${name}" during cleanup - the search filter "${namePrefix}" may not be applied.`);
        }

        await row.locator("td").last().locator("button").click();
        await page.waitForSelector(confirmSelector, { state: "visible", timeout: 15000 });
        await page.click(confirmSelector);
        await waitFor(async () => (await page.locator(rowsSelector).filter({ hasText: name }).count()) === 0, {
            timeout: 20000,
            expected: `wishlist row "${name}" to disappear after confirming deletion`,
        });
    }
});

// Deletes exactly one named row from a table (e.g. a wishlist list), via
// that row's own last-cell delete button and the shared "Confirm deletion
// proceed" dialog button - same table/dialog shape as the cleanup loop
// above, but for a single, deliberate delete rather than a safety-checked
// sweep. Reusable by any project with a similar named-row-with-delete-
// button table.
const deleteRowContaining = async (page: ScenarioWorld["screen"]["page"], globalConfig: ScenarioWorld["globalConfig"], name: string, rowsKey: string) => {
    const rowsSelector = getElementLocator(page, rowsKey, globalConfig);
    const confirmSelector = getElementLocator(page, "Confirm deletion proceed", globalConfig);

    const row = page.locator(rowsSelector).filter({ hasText: name });
    await row.locator("td").last().locator("button").click();
    await page.waitForSelector(confirmSelector, { state: "visible", timeout: 15000 });
    await page.click(confirmSelector);
    await waitFor(async () => (await page.locator(rowsSelector).filter({ hasText: name }).count()) === 0, {
        timeout: 20000,
        expected: `row containing "${name}" to disappear from the "${rowsKey}" (${rowsSelector}) table after confirming deletion`,
    });
};

Then(/^I delete the row containing "([^"]*)" from the "([^"]*)" table$/, async function (this: ScenarioWorld, name: string, rowsKey: string) {
    const { screen: { page }, globalConfig } = this;
    await deleteRowContaining(page, globalConfig, name, rowsKey);
});

// The remembered-value counterpart to the step above - for a row whose
// identity is a runtime-generated value (e.g. a unique wishlist name)
// stashed earlier via "I fill in the ... with a unique value, remembering
// it as ...", not a literal a scenario can spell out.
Then(/^I delete the row containing the remembered "([^"]*)" from the "([^"]*)" table$/, async function (this: ScenarioWorld, variableName: string, rowsKey: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
        throw new Error(`No remembered text found for "${variableName}" - "I fill in the ... with a unique value, remembering it as ..." must run first.`);
    }
    await deleteRowContaining(page, globalConfig, remembered, rowsKey);
});

// For a sort toggle whose exact collation order isn't worth asserting (a
// name list mixing letters/digits/spaces can sort non-obviously) - only
// that clicking once changes the order, and clicking again produces the
// EXACT reverse, which holds regardless of collation. rowKey should resolve
// to every row (e.g. a table's <tr> elements); this reads each row's own
// first cell as its identity. Reusable by any project with a similar
// sortable-list-of-rows shape.
Then(/^clicking the "([^"]*)" button twice should reverse the "([^"]*)" row order$/, async function (this: ScenarioWorld, sortButtonKey: string, rowKey: string) {
    const { screen: { page }, globalConfig } = this;
    const sortButtonSelector = getElementLocator(page, sortButtonKey, globalConfig);
    const rowsSelector = getElementLocator(page, rowKey, globalConfig);
    const readRowNames = () => page.locator(rowsSelector).locator("td:first-child").allTextContents();

    const originalOrder = await readRowNames();

    await page.click(sortButtonSelector);
    const firstClickOrder = await waitFor(async (): Promise<string[] | undefined> => {
        const order = await readRowNames();
        return order.join("|") !== originalOrder.join("|") ? order : undefined;
    }, {
        expected: `the "${rowKey}" (${rowsSelector}) row order to change after clicking "${sortButtonKey}" (${sortButtonSelector})`,
        describeActual: async () => `order is still ${JSON.stringify(await readRowNames())}`,
    });

    if (!firstClickOrder) {
        throw new Error("waitFor resolved without a row order - this should be unreachable.");
    }
    const expectedReversedOrder = [...firstClickOrder].reverse().join("|");

    await page.click(sortButtonSelector);
    await waitFor(async () => {
        const order = await readRowNames();
        return order.join("|") === expectedReversedOrder;
    }, {
        expected: `the "${rowKey}" (${rowsSelector}) row order to reverse back after clicking "${sortButtonKey}" (${sortButtonSelector}) a second time`,
        describeActual: async () => `order is ${JSON.stringify(await readRowNames())}, expected the reverse of ${JSON.stringify(firstClickOrder)}`,
    });
});
