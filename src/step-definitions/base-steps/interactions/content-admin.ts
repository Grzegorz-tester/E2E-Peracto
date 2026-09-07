import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { enterValue, getValue } from "../../support-functions/html-behaviour";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { ElementKey } from "../../../env/global";

// Peracto Admin's Content > Pages/Articles both auto-generate their slug
// from this one title field on blur (confirmed live, MIPA_ADMIN staging,
// 2026-08-30 - no second "Title" field needs filling for a save to
// succeed). A readable date-time (not product-admin.ts's raw
// `Date.now()`) is baked into the value itself, on request, so a person
// looking at the Pages/Articles list or the Orphaned Pages menu later can
// see exactly when a given test row was created without cross-referencing
// a test run. Stashed in globalVariables the same way product-admin.ts
// stashes its product name/SKU, since this same value is needed again
// later in the scenario (searching the "Select Item" react-select,
// confirming it landed in the menu, then cleaning both up).
When(/^I fill in the "([^"]*)" input field with a unique test title$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const timestamp = new Date().toISOString().replace("T", " ").replace(/\.\d+Z$/, "");
    const title = `Velstar Test Content ${timestamp}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await enterValue(page, elementIdentifier, title);
    // The slug field only recomputes on blur, not on every keystroke -
    // confirmed live: reading it straight after fill() (which leaves focus
    // in the field) still showed the slug empty.
    await page.locator(elementIdentifier).blur();

    this.globalVariables["content title"] = title;
});

Then(/^the "([^"]*)" input field should have the stored content title$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const title = this.globalVariables["content title"];
    if (!title) {
        throw new Error(`No stored content title found - "I fill in the ... with a unique test title" must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await waitFor(async () => (await getValue(page, elementIdentifier)) === title, {
        expected: `"${elementKey}" (${elementIdentifier}) to have the stored content title "${title}"`,
        describeActual: async () => `value was "${(await getValue(page, elementIdentifier).catch(() => null)) ?? "(could not read value)"}"`,
    });
});

// The "Select Item" react-select on Peracto Admin's Add Menu Item modal is
// an async search box, not a pre-populated list - confirmed live: opening
// it with no query just shows "Enter text to begin searching." rather
// than the existing "... react-select" step's already-rendered
// `.list__option`s. Typing the stored content title is exactly the search
// term that finds our own just-created page/article (both this and that
// step share the same "list" classNamePrefix react-select shape, so the
// same `.list__menu`/`.list__option` classes apply once results load).
When(/^I search for the stored content title in the "([^"]*)" react-select$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const title = this.globalVariables["content title"];
    if (!title) {
        throw new Error(`No stored content title found - "I fill in the ... with a unique test title" must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const control = page.locator(elementIdentifier);
    await control.waitFor({ state: "visible", timeout: 15000 });
    await control.click();
    await control.locator("input").first().type(title, { delay: 30 });

    const menu = page.locator(".list__menu:visible").last();
    const option = menu.getByText(title, { exact: true });
    await option.waitFor({ state: "visible", timeout: 10000 });
    await option.click();
});

// The "any of several matching elements" check needed here (e.g. one row
// among many in the Orphaned Pages menu tree) is now the generic
// "the remembered ... should appear in the ... element" step in
// verify-element-value.ts - "content title" is just this scenario's own
// variable name for it, nothing content-specific about the mechanism
// itself.

// Cleanup counterpart to "with a unique test title" - deletes the
// Pages/Articles list row for whatever was just created, via the same
// checkbox-select -> "Delete Row" -> confirm-modal flow used generically
// across Peracto Admin's list pages (confirmed live identical on both
// Pages and Articles). Deliberately finds the row by the STORED title
// text rather than "first row", since that's the only thing distinguishing
// our disposable test row from any other real row already in the list.
When(/^I delete the content row containing the stored content title$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;
    const title = this.globalVariables["content title"];
    if (!title) {
        throw new Error(`No stored content title found - "I fill in the ... with a unique test title" must run first.`);
    }

    const rowIdentifier = getElementLocator(page, "table row", globalConfig);
    const checkboxIdentifier = getElementLocator(page, "row checkbox", globalConfig);
    const deleteIdentifier = getElementLocator(page, "Delete Row", globalConfig);
    const confirmIdentifier = getElementLocator(page, "Confirm Delete Row", globalConfig);

    const row = page.locator(rowIdentifier).filter({ hasText: title });
    await row.waitFor({ state: "visible", timeout: 15000 });
    await row.locator(checkboxIdentifier).check({ force: true });
    await page.click(deleteIdentifier);

    // Confirmed live: this modal's own markup is duplicated in the DOM (a
    // second, hidden copy shared with the "Duplicate" action's confirm
    // dialog) - waitForSelector on the bare selector kept timing out
    // polling the first (hidden) match. .last() targets the one that's
    // actually visible, same fix as the raw exploratory script that first
    // confirmed this delete flow.
    const confirmButton = page.locator(confirmIdentifier).last();
    await confirmButton.waitFor({ state: "visible", timeout: 10000 });
    await confirmButton.click();
    await row.waitFor({ state: "detached", timeout: 10000 });
});

// Cleanup counterpart for the menu-tree side: the Orphaned Pages (or any
// other) menu's own "Remove Item" flow, scoped to the row containing our
// stored title the same way the content-list cleanup above is - a menu can
// hold many real, unrelated items (confirmed live: 17 pre-existing rows on
// MIPA's Orphaned Pages menu), so this must remove ONLY the disposable row
// this scenario itself added.
When(/^I remove the stored content title from the "([^"]*)" navigation menu$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const title = this.globalVariables["content title"];
    if (!title) {
        throw new Error(`No stored content title found - "I fill in the ... with a unique test title" must run first.`);
    }

    const rowIdentifier = getElementLocator(page, elementKey, globalConfig);
    const removeButtonIdentifier = getElementLocator(page, "Remove Item", globalConfig);
    const confirmIdentifier = getElementLocator(page, "Confirm Remove Item", globalConfig);

    const row = page.locator(rowIdentifier).filter({ hasText: title });
    await row.waitFor({ state: "visible", timeout: 15000 });
    await row.locator(removeButtonIdentifier).click();
    await page.waitForSelector(confirmIdentifier, { state: "visible", timeout: 10000 });
    await page.click(confirmIdentifier);
    await row.waitFor({ state: "detached", timeout: 10000 });
});
