import { Given, Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// The staff Quote Builder duplicates every row (mobile/desktop breakpoint
// variants) throughout, exactly like the rest of this storefront - every
// locator here is scoped to :visible for that reason.

// Deliberately a PLAIN (non-forced) click, unlike the generic "I click on
// the X button/tab" step - that step's force:true bypasses Playwright's
// "receives events" check, which is right for the map-widget case it was
// added for but wrong here: confirmed live that force-clicking these tabs
// can silently land on whatever DOES receive the event at that point
// instead of the tab underneath, leaving the wrong tab's content on screen
// with no visible error. A real click only succeeds once the tab is
// genuinely the topmost element there.
When(/^I switch to the "([^"]*)" quote tab$/, async function (this: ScenarioWorld, tabKey: string) {
    const { screen: { page }, globalConfig } = this;
    const tabSelector = getElementLocator(page, tabKey, globalConfig);
    await page.locator(tabSelector).click({ timeout: 15000 });
});

// Deliberately waits for the underlying PUT to actually complete rather
// than reusing the generic "I click on the X button" step - the
// "You have unsaved changes" banner never goes away on its own (it's
// permanently present whenever a live-vs-quoted price mismatch exists,
// unrelated to whether THIS save succeeded), so it can't be used as a
// signal, and proceeding immediately after the click risks reloading
// before the save has actually persisted server-side.
When(/^I save the quote and wait for it to persist$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;
    const saveSelector = getElementLocator(page, "save button", globalConfig);

    const [response] = await Promise.all([
        page.waitForResponse(
            (r) => /staging-api\.[^/]+\/quotes\/[^/?]+$/.test(r.url()) && r.request().method() === "PUT",
            { timeout: 15000 },
        ),
        page.locator(saveSelector).click(),
    ]);
    expect(response.status()).toBeLessThan(300);
});

// Creates a disposable copy of whatever quote is currently open, so
// destructive Products/Details Tab testing never touches a real customer's
// quote. CONFIRMED FLAKY UNDER AUTOMATION: this occasionally surfaces an
// "Internal Server Error" on the client even though the duplicate quote is
// created successfully server-side (confirmed via network inspection) - a
// transient staging issue, not a defect in this step. Retrying the whole
// action rides out that flakiness.
Given(/^I duplicate this quote for a company matching "([^"]*)" and use the copy$/, async function (this: ScenarioWorld, companyText: string) {
    const { screen: { page }, globalConfig } = this;

    const kebabSelector = getElementLocator(page, "quote kebab menu button", globalConfig);
    const companyInputSelector = getElementLocator(page, "duplicate quote company input", globalConfig);
    const confirmSelector = getElementLocator(page, "duplicate quote confirm button", globalConfig);

    await waitFor(async () => {
        const urlBefore = page.url();

        // Each attempt must catch its own failures rather than let them
        // propagate - an uncaught throw here would abort the whole waitFor
        // loop on the first try instead of actually retrying.
        try {
            await page.locator(kebabSelector).first().click();
            const menuItem = page.locator('[role="menuitem"]:visible:has-text("Duplicate Quote")');
            await menuItem.waitFor({ state: "visible", timeout: 5000 });
            await menuItem.click();

            // NOT scoped through the modal's own [role="dialog"] wrapper -
            // confirmed live that this particular dialog's outer element
            // reports a zero-height bounding box to Playwright (its
            // fixed-position/flex-centered children don't force it to
            // report an intrinsic size) even while fully visible and
            // interactive on screen, so waiting on ITS visibility never
            // resolves. The inner fields have their own correct, real
            // bounding boxes and are actionable directly.
            await page.locator(companyInputSelector).click({ timeout: 5000 });
            await page.locator(".select-search-option", { hasText: companyText }).first().click({ timeout: 5000 });
            await page.locator(confirmSelector).click({ timeout: 5000 });

            await page.waitForURL(
                (url) => url.toString() !== urlBefore && /\/account\/staff-quotes\/[^/]+$/.test(url.toString()),
                { timeout: 8000 },
            );

            // CONFIRMED SITE BUG: after confirming, the modal's portal root
            // stays mounted (a client-side route change doesn't unmount
            // it) and its now-invisible overlay keeps intercepting pointer
            // events across the WHOLE page indefinitely - Escape doesn't
            // clear it either. A full reload is the only reliable way to
            // land on the new quote's page in an actually-interactable
            // state.
            await page.reload({ waitUntil: "domcontentloaded", timeout: 15000 });
            return true;
        } catch {
            await page.keyboard.press("Escape").catch(() => {});
            return false;
        }
        // Budget kept comfortably under Cucumber's own SCRIPT_TIMEOUT (20s)
        // so a run of bad luck surfaces this waitFor's own clear error
        // instead of a step-level timeout.
    }, { timeout: 15000, wait: 500 });
});

When(/^I create a new section named "([^"]*)"$/, async function (this: ScenarioWorld, sectionName: string) {
    const { screen: { page }, globalConfig } = this;

    const nameInputSelector = getElementLocator(page, "create section name input", globalConfig);
    const createButtonSelector = getElementLocator(page, "create section button", globalConfig);

    await page.locator(nameInputSelector).fill(sectionName);
    await page.locator(createButtonSelector).click();

    await waitFor(() => page.locator(`:visible:text("${sectionName}")`).first().isVisible());
});

// Scoped to the LAST matching input on the page, since a just-created
// section's own catalogue-item search box is always the most recently
// appended one - avoids needing to disambiguate between every section's
// identical-looking search input by name.
When(/^I add the catalogue item matching "([^"]*)" to the section I just created$/, async function (this: ScenarioWorld, skuFragment: string) {
    const { screen: { page } } = this;

    const searchInput = page.locator(':text-is("Add Catalogue Item") + input:visible').last();
    await searchInput.click();
    await searchInput.type(skuFragment, { delay: 50 });

    const firstOption = page.locator(".shadow-lg [role=\"button\"]:visible").first();
    await firstOption.waitFor({ state: "visible", timeout: 10000 });
    await firstOption.click();
});

When(/^I add a custom item named "([^"]*)" to the section I just created$/, async function (this: ScenarioWorld, itemName: string) {
    const { screen: { page }, globalConfig } = this;

    const nameInputSelector = getElementLocator(page, "custom item name input", globalConfig);
    const nameInput = page.locator(nameInputSelector).last();
    await nameInput.click();
    await nameInput.type(itemName, { delay: 30 });
    await nameInput.press("Enter");

    await waitFor(() => page.locator(`:visible:text("${itemName}")`).first().isVisible());
});

// Not scoped to a specific section/row - the text given to each scenario
// (a section name, a custom item name, a note) is unique enough (freshly
// created, not shared catalogue data) that checking it renders anywhere on
// the page is a reliable proxy for "it was added in the right place",
// without the fragility of walking the DOM up from a heading to its rows.
Then(/^the text "([^"]*)" should be displayed on the quote$/, async function (this: ScenarioWorld, text: string) {
    const { screen: { page } } = this;
    await expect(page.locator(`:visible:text("${text}")`).first()).toBeVisible({ timeout: 15000 });
});

// A saved section renders its own row of action buttons (Edit/Discount/
// Duplicate/Delete/Reorder) - a brand new, not-yet-saved section doesn't
// have them yet (confirmed live: they only appear once the section is
// persisted). Scoping by "visible element containing both the section's
// name AND its own 'Subtotal' text" reliably isolates that one section's
// own container instead of the whole page.
const sectionContainer = (page: import("playwright").Page, sectionName: string) =>
    page.locator(":visible").filter({ hasText: sectionName }).filter({ hasText: "Subtotal" }).last();

// The discount modal is the SAME shared component regardless of whether it
// was opened from the quote-level "APPLY ADDITIONAL DISCOUNT" button, a
// section's own "Discount" button, or (for a product) its "Edit Product"
// menu item's own discount field - it always titles itself "Edit <quote
// name>" and submits via "APPLY ADDITIONAL DISCOUNT", regardless of which
// level is actually being discounted. Distinguishing the level is purely a
// matter of which trigger got clicked, not anything visible in the modal
// itself.
async function fillAndSubmitDiscountModal(page: import("playwright").Page, globalConfig: import("../../../env/global").GlobalConfig, discount: string) {
    const discountInputSelector = getElementLocator(page, "discount modal input", globalConfig);
    const submitSelector = getElementLocator(page, "discount modal submit button", globalConfig);

    await page.locator(discountInputSelector).fill(discount);
    await page.locator(submitSelector).click();
}

When(/^I apply an additional discount of "([^"]*)" to the whole quote$/, async function (this: ScenarioWorld, discount: string) {
    const { screen: { page }, globalConfig } = this;
    const triggerSelector = getElementLocator(page, "apply additional discount button", globalConfig);

    await page.locator(triggerSelector).click();
    await fillAndSubmitDiscountModal(page, globalConfig, discount);
});

When(/^I apply a discount of "([^"]*)" to the "([^"]*)" section$/, async function (this: ScenarioWorld, discount: string, sectionName: string) {
    const { screen: { page }, globalConfig } = this;

    await sectionContainer(page, sectionName).locator('button:text-is("Discount")').click();
    await fillAndSubmitDiscountModal(page, globalConfig, discount);
});

Then(/^the "([^"]*)" discount value should still read "([^"]*)"$/, async function (this: ScenarioWorld, sectionName: string, expectedValue: string) {
    const { screen: { page } } = this;

    await sectionContainer(page, sectionName).locator('button:text-is("Discount")').click();
    const discountInput = page.locator('[role="dialog"] input[name="discount"]');
    await expect(discountInput).toHaveValue(expectedValue, { timeout: 10000 });
    await page.keyboard.press("Escape");
});

When(/^I apply a discount of "([^"]*)" to the product named "([^"]*)"$/, async function (this: ScenarioWorld, discount: string, productName: string) {
    const { screen: { page }, globalConfig } = this;

    const row = page.locator("tr:visible", { hasText: productName }).first();
    await row.locator('[role="menubar"]').click();
    await page.locator('[role="menuitem"]:visible:has-text("Edit Product")').click();

    // This modal has no explicit Save button - the discount field applies
    // to the quote's local (unsaved) state as soon as it changes, same as
    // every other in-place edit on this Products tab. Closing it via the X
    // just returns to the main view.
    const discountInputSelector = getElementLocator(page, "product edit modal discount input", globalConfig);
    const closeSelector = getElementLocator(page, "product edit modal close button", globalConfig);
    await page.locator(discountInputSelector).fill(discount);
    await page.locator(discountInputSelector).press("Tab");
    await page.locator(closeSelector).click();
});

When(/^I duplicate the "([^"]*)" section$/, async function (this: ScenarioWorld, sectionName: string) {
    const { screen: { page } } = this;
    await sectionContainer(page, sectionName).locator('button:text-is("Duplicate")').click();
});

When(/^I delete the "([^"]*)" section$/, async function (this: ScenarioWorld, sectionName: string) {
    const { screen: { page } } = this;
    await sectionContainer(page, sectionName).locator('button:text-is("Delete")').click();
});

When(/^I duplicate the product named "([^"]*)"$/, async function (this: ScenarioWorld, productName: string) {
    const { screen: { page } } = this;
    const row = page.locator("tr:visible", { hasText: productName }).first();
    await row.locator('[role="menubar"]').click();
    await page.locator('[role="menuitem"]:visible:has-text("Duplicate Product")').click();
});

When(/^I delete the product named "([^"]*)"$/, async function (this: ScenarioWorld, productName: string) {
    const { screen: { page } } = this;
    const row = page.locator("tr:visible", { hasText: productName }).first();
    await row.locator('[role="menubar"]').click();
    await page.locator('[role="menuitem"]:visible:has-text("Delete Product")').click();
});

// Three near-identical modals (Add Note/Add Internal Note/Add S43 Project
// No.), each reachable only from the kebab menu and each with its own
// differently-named field and submit button - kept as three explicit
// steps rather than one parameterised step, since the field name and
// submit label don't derive from the menu item text in any predictable way.
async function openQuoteKebabMenuItem(page: import("playwright").Page, globalConfig: import("../../../env/global").GlobalConfig, menuItemText: string) {
    const kebabSelector = getElementLocator(page, "quote kebab menu button", globalConfig);
    await page.locator(kebabSelector).first().click();
    await page.locator(`[role="menuitem"]:visible:has-text("${menuItemText}")`).click();
}

// Waits for the PRIOR modal to actually finish closing before the next
// kebab-menu action opens a new one - these modals share the same
// zero-height-wrapper quirk documented on the duplicate-quote modal above,
// and confirmed live that leaving one open/mid-close can silently block
// the next kebab click from landing correctly.
async function closeModal(page: import("playwright").Page) {
    await page.locator('[role="dialog"] button:has(svg[data-icon="xmark"])').first().click().catch(() => {});
    await page.waitForSelector('[role="dialog"]', { state: "detached", timeout: 5000 }).catch(() => {});
}

When(/^I add a note "([^"]*)" to the quote$/, async function (this: ScenarioWorld, note: string) {
    const { screen: { page }, globalConfig } = this;
    await openQuoteKebabMenuItem(page, globalConfig, "Add Note");
    await page.locator('[role="dialog"] input[name="note"]').fill(note);
    await page.locator('[role="dialog"] button:has-text("Update Note")').click();
    await closeModal(page);
});

When(/^I add an internal note "([^"]*)" to the quote$/, async function (this: ScenarioWorld, note: string) {
    const { screen: { page }, globalConfig } = this;
    await openQuoteKebabMenuItem(page, globalConfig, "Add Internal Note");
    await page.locator('[role="dialog"] input[name="internalNote"]').fill(note);
    await page.locator('[role="dialog"] button:has-text("Update Internal Note")').click();
    await closeModal(page);
});

When(/^I add S43 project number "([^"]*)" to the quote$/, async function (this: ScenarioWorld, projectNumber: string) {
    const { screen: { page }, globalConfig } = this;
    await openQuoteKebabMenuItem(page, globalConfig, "Add S43 Project No.");
    await page.locator('[role="dialog"] input[name="system43QuoteReference"]').fill(projectNumber);
    await page.locator('[role="dialog"] button:has-text("Update S43")').click();
    await closeModal(page);
});

// LAST step of the whole flow - permanently removes the scratch quote this
// feature duplicated at the start, so nothing accumulates on staging across
// repeated runs.
When(/^I delete this quote$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;
    await openQuoteKebabMenuItem(page, globalConfig, "Delete Quote");
    await page.locator('[role="dialog"] button:has-text("DELETE QUOTE")').click();
});
