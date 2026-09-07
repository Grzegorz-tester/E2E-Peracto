import {DataTable, When} from "@cucumber/cucumber";
import {Locator, Page} from "playwright";
import {ElementKey} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {clickElementAtIndex, enterValue, selectDropdownOption} from "../../support-functions/html-behaviour";
import {navigateToPage} from "../../support-functions/navigation-behaviour";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {ScenarioWorld} from "../../setup/world";

// Sources the value from users.json/env vars instead of literal Gherkin text,
// so real credentials never need to be hardcoded in a .feature file (e.g. to
// deliberately test a wrong-password login while still using a real email).
When(/^I fill in the "([^"]*)" input field with the "([^"]*)" user's (email|password)$/, async function (this: ScenarioWorld, elementKey: ElementKey, userType: string, field: "email" | "password") {
    const {
        screen: {page},
        globalConfig
    } = this;

    const user = globalConfig.usersConfig[userType.trim().toLowerCase()];
    const value = user?.[field];
    if (!value) {
        throw new Error(`Missing "${field}" for user type "${userType}". Check your users.json and env vars.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    // waitForSelector already throws (rather than returning falsy) on
    // timeout, so wrapping it in waitFor's retry loop below never actually
    // retries - the loop's own error message never fires. Give it an
    // explicit timeout with headroom under SCRIPT_TIMEOUT instead.
    await page.waitForSelector(elementIdentifier, { timeout: 15000 });
    await enterValue(page, elementIdentifier, value);
});

// For a field that just needs to be non-empty and collision-free (e.g. a
// warranty lookup's serial number), rather than a real email address - see
// "... with a unique guest email" above for the email-shaped equivalent.
When(/^I fill in the "([^"]*)" input field with a unique value$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { timeout: 15000 });
    await enterValue(page, elementIdentifier, `qa-${Date.now()}`);
});

// Same disposable "qa-<ts>" value as "... with a unique value" above, but
// also stashes it in globalVariables - for a scenario that needs to find
// this exact row/element again later (e.g. to edit or delete whatever it
// just created), not just fill the field once and move on.
When(/^I fill in the "([^"]*)" input field with a unique value, remembering it as "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const value = `qa-${Date.now()}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { timeout: 15000 });
    await enterValue(page, elementIdentifier, value);

    this.globalVariables[variableName] = value;
});

// The fill-side counterpart to verify-element-value.ts's "I remember the
// text of ... as ..." / "should contain the remembered ..." pair - for
// carrying a live, page-read value (e.g. a real product's own SKU) INTO a
// later field, not just comparing against it. Avoids hardcoding a specific
// SKU/value that could stop existing (or change) later, the same reason
// this suite prefers "click the first item" over a fixed one elsewhere.
When(/^I fill in the "([^"]*)" input field with the remembered "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
        throw new Error(`No remembered text found for "${variableName}" - "I remember the text of ... as ..." must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.waitForSelector(elementIdentifier, { timeout: 15000 });
    await enterValue(page, elementIdentifier, remembered);
});

When(/^I fill in the "([^"]*)" input field with "([^"]*)"$/, async function (elementKey: ElementKey, inputText: string) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { timeout: 15000 });
    await enterValue(page, elementIdentifier, inputText);
});


// The Algolia search-results autocomplete is debounced and re-renders as
// the query resolves. Without this, a fast test can assert "search results
// displayed" and click the "first search result" while it's still showing
// the previous/default result set, landing on the wrong product instead of
// a "<term>"-matching one.
When(/^I wait for the search results to update$/, async function () {
    await new Promise((resolve) => setTimeout(resolve, 1500));
});

// For a search box (or any input) whose submit action is pressing Enter
// rather than clicking a separate button - e.g. Watco's header search,
// which navigates straight to a /search results page on Enter.
When(/^I press Enter in the "([^"]*)" input field$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.press(elementIdentifier, "Enter");
});

// A leading "<digits><st|nd|rd|th>" option (e.g. "2nd") selects by
// POSITION instead of matching text - for a dropdown whose option text is
// translated per-market (e.g. a title select showing "Mr"/"Herr"/"M."/
// etc. depending on locale) where the exact wording of any one specific
// option isn't worth hardcoding/guessing per market. Same choice the
// source Playwright suite this was migrated from deliberately makes for
// exactly this reason. "1st" is index 0, "2nd" is index 1, etc. One step
// definition (not two) - a separate ordinal-only regex would be
// ambiguous with this one, since "2nd" also matches `[^"]*`.
When(/^I select the "([^"]*)" option from the "([^"]*)" dropdown$/, async function (option: string, elementKey: ElementKey) {
    const {
        screen: {page},

        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });

    const ordinalMatch = option.match(/^(\d+)(?:st|nd|rd|th)$/);
    if (ordinalMatch) {
        await page.focus(elementIdentifier);
        await page.selectOption(elementIdentifier, { index: Number(ordinalMatch[1]) - 1 });
    } else {
        await selectDropdownOption(page, elementIdentifier, option);
    }
});

// For a Radix-style combobox (a <button role="combobox"> that opens a
// role="listbox" popup of role="option" divs) rather than a native
// <select> - confirmed live on Indespension's towbar vehicle-search
// filter (Make/Model/Year/Body Type). The "... dropdown" step above only
// works on a real <select> (it calls page.selectOption, which throws on
// anything else) - there was no generic step for this combobox shape
// anywhere in the repo before this, despite it being a common shadcn/
// Radix UI pattern likely to recur on other projects. A leading ordinal
// (e.g. "1st") selects by position, same convention as "... dropdown"
// above, for a combobox whose option text varies (year ranges, per-make
// model lists) where no specific value is worth hardcoding.
//
// The mapping's own selector should point directly at the
// button[role='combobox'] itself (not a wrapping container) - confirmed
// live this matters: Playwright's isEnabled()/isDisabled() checks the
// exact resolved element, and a plain wrapper <div> can never be "HTML
// disabled" regardless of an inner button's real state, which silently
// breaks any "should/should not be enabled" assertion reusing the same
// mapping key. If the resolved element isn't itself the combobox button,
// this falls back to searching inside it, so a container-style mapping
// still works for opening the listbox - just not for that enabled check.
//
// "last" (alongside the numeric ordinals) is for a listbox whose option
// COUNT varies run-to-run and where the last one specifically is what a
// scenario needs, not just "some real option" - confirmed live need on
// Indespension's towbar fitting date picker: only a later week's slots
// are genuinely bookable (an imminent/current week can be entirely past
// its own booking cutoff), and how many weeks ahead are offered shifts
// over time, so hardcoding a numeric position would silently start
// picking the wrong week as the list grows or shrinks.
When(/^I select the "([^"]*)" option from the "([^"]*)" listbox$/, async function (this: ScenarioWorld, option: string, elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const resolved = page.locator(elementIdentifier);
    const isComboboxItself = await resolved.getAttribute("role").catch(() => null) === "combobox";
    const trigger = isComboboxItself ? resolved : resolved.locator("button[role='combobox']");
    await trigger.waitFor({ state: "visible", timeout: 15000 });

    // Same hydration-race shape already confirmed elsewhere in this repo
    // (logging-in.feature, the PDP "Add to basket" button): a click fired
    // the instant this Radix trigger is "visible and stable" can silently
    // no-op if its onClick handler isn't attached yet - confirmed live,
    // this only reproduces when the click follows page navigation
    // immediately (as a Background/Given step does), not when there's
    // already been some delay. Retrying once against the real success
    // signal (the listbox actually opening) rather than a fixed sleep.
    const listbox = page.locator("[role='listbox']:visible").last();
    const listOptions = listbox.locator("[role='option']");
    await trigger.click();
    const openedFirstTry = await listOptions.first()
        .waitFor({ state: "visible", timeout: 5000 })
        .then(() => true)
        .catch(() => false);
    if (!openedFirstTry) {
        await trigger.click();
        await listOptions.first().waitFor({ state: "visible", timeout: 15000 });
    }

    if (option === "last") {
        await listOptions.last().click();
        return;
    }
    const ordinalMatch = option.match(/^(\d+)(?:st|nd|rd|th)$/);
    if (ordinalMatch) {
        await listOptions.nth(Number(ordinalMatch[1]) - 1).click();
        return;
    }
    await listbox.getByText(option, { exact: true }).click();
});

// For a listbox whose real-world availability varies not just WITHIN one
// option but ACROSS options too - confirmed live need on Indespension's
// towbar fitting-date picker: picking a specific week (even "the last
// available one") isn't enough on its own, since a whole week's worth of
// slots can become entirely booked out (this is a REAL booking flow, not
// a mock - repeated test runs against the same week exhaust it exactly
// like real customers would). Tries each week option from the END of the
// list backwards (later weeks are less likely to already be exhausted
// than nearer ones) until candidateKey has at least one enabled match,
// re-opening the listbox between attempts since selecting an option
// closes it. Leaves the viable option selected; actually clicking the
// candidate is the separate "I click on the first enabled ... button"
// step, composed with this one rather than folded into it.
//
// Needs its own generous step timeout (same convention as checkout.ts's
// Verifone payment step): trying N weeks backwards, each waiting up to
// 15s to see whether it has any enabled candidate, can comfortably
// exceed this framework's global default step timeout (20s, from
// SCRIPT_TIMEOUT) well before this function's own loop finishes and
// throws its own clear error - confirmed live, that showed up as an
// opaque "function timed out" from cucumber itself instead, well before
// every week had even been tried.
// For Peracto Admin's classic react-select widget (classNamePrefix "list",
// no ARIA roles at all) - confirmed live on Carbon Admin's Add Product
// form: Product Type/Status/Availability/Sales Unit/Tax rate/Attribute Set
// all render this way, none of them a real <select> (so the "... dropdown"
// step's page.selectOption throws) or a role=combobox/listbox/option
// widget (so the "... listbox" step above can't find a trigger or
// options either). Confirmed identical shape across Peracto Admin tenants
// per CLAUDE.md ("KOOL, Indespension and Carbon Admin... run the same
// underlying Peracto Admin product"), so this is expected to be reusable
// wherever a future scenario needs to drive one of these fields, not just
// this one form. The mapping's own selector should point at the
// react-select's outer container (the same element you'd click to open
// it), same convention as the "... listbox" step's trigger.
When(/^I select the "([^"]*)" option from the "([^"]*)" react-select$/, async function (this: ScenarioWorld, option: string, elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const control = page.locator(elementIdentifier);
    await control.waitFor({ state: "visible", timeout: 15000 });
    await control.click();

    const menu = page.locator(".list__menu:visible").last();
    await menu.locator(".list__option").first().waitFor({ state: "visible", timeout: 10000 });
    await menu.getByText(option, { exact: true }).click();
});

// Shared by the two steps below: tries every option in an already-open-able
// combobox from the end of the list backwards until candidateIdentifier has
// at least one enabled match, re-opening the listbox between attempts since
// selecting an option closes it. Returns whether one was found instead of
// throwing, so the multi-postcode step below can fall through to its next
// postcode instead of failing outright the moment one centre's calendar
// comes up empty.
const selectOptionWithEnabledCandidate = async (
    page: Page,
    trigger: Locator,
    candidateIdentifier: string
): Promise<boolean> => {
    // force:true on the trigger click here specifically: confirmed live
    // that re-opening this same combobox on a LATER iteration (after
    // having already opened and closed it once) can leave a lingering,
    // invisible full-page overlay intercepting pointer events at the
    // <html> root - a leftover Radix Portal element from the previous
    // close, not a real modal - which otherwise blocks the plain click
    // outright (confirmed live: 60+ retries, never clearing on its own).
    // Safe here since the trigger is a real, normal-sized button, not an
    // oversized wrapper (the case force:true is documented elsewhere in
    // this repo as breaking).
    const openListbox = async () => {
        const listbox = page.locator("[role='listbox']:visible").last();
        const listOptions = listbox.locator("[role='option']");
        await trigger.click({ force: true });
        const openedFirstTry = await listOptions.first()
            .waitFor({ state: "visible", timeout: 5000 })
            .then(() => true)
            .catch(() => false);
        if (!openedFirstTry) {
            await trigger.click({ force: true });
            await listOptions.first().waitFor({ state: "visible", timeout: 15000 });
        }
        return listOptions;
    };

    const optionCount = await (await openListbox()).count();

    for (let i = optionCount - 1; i >= 0; i--) {
        const listOptions = await openListbox();
        await listOptions.nth(i).click();

        const candidates = page.locator(candidateIdentifier);
        const candidatesRendered = await candidates.first()
            .waitFor({ state: "visible", timeout: 15000 })
            .then(() => true)
            .catch(() => false);
        if (!candidatesRendered) {
            continue;
        }

        // Confirmed live: candidates render as visible immediately but start
        // out disabled - the real availability data loads asynchronously
        // ~1-1.5s later. Checking isEnabled() only once, right after the
        // visibility wait above, catches every candidate in this transient
        // disabled state and reports zero availability even when the vast
        // majority of slots are genuinely open (this is what produced the
        // earlier "genuine inventory exhaustion" theory - it wasn't real).
        // Poll for a few seconds instead of checking once.
        const anyEnabled = await waitFor(async () => {
            const candidateCount = await candidates.count();
            for (let c = 0; c < candidateCount; c++) {
                if (await candidates.nth(c).isEnabled()) {
                    return true;
                }
            }
            return false;
        }, { timeout: 5000, wait: 250 }).catch(() => false);

        if (anyEnabled) {
            return true;
        }
    }
    return false;
};

const resolveComboboxTrigger = async (page: Page, elementIdentifier: string): Promise<Locator> => {
    const resolved = page.locator(elementIdentifier);
    const isComboboxItself = await resolved.getAttribute("role").catch(() => null) === "combobox";
    const trigger = isComboboxItself ? resolved : resolved.locator("button[role='combobox']");
    await trigger.waitFor({ state: "visible", timeout: 15000 });
    return trigger;
};

When(/^I select an option from the "([^"]*)" listbox with an enabled "([^"]*)" candidate$/, { timeout: 90000 }, async function (this: ScenarioWorld, listboxKey: ElementKey, candidateKey: ElementKey) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, listboxKey, globalConfig);
    const candidateIdentifier = getElementLocator(page, candidateKey, globalConfig);
    const trigger = await resolveComboboxTrigger(page, elementIdentifier);

    const found = await selectOptionWithEnabledCandidate(page, trigger, candidateIdentifier);
    if (!found) {
        throw new Error(`No option in the "${listboxKey}" listbox left an enabled "${candidateKey}" candidate.`);
    }
});

// For a REAL, live booking calendar (not a fixture) where a single centre
// can go from a couple of open slots to zero within minutes of real demand
// - confirmed live, twice, on Indespension's towbar fitting booking
// (2026-08-27): Portsmouth (PO7 6QX) had 2/10 slots enabled in its nearest
// week, then 0/10 across every week two minutes later when the actual
// scenario reached that step. The per-week retry above already handles one
// centre's calendar being unevenly booked across weeks; this handles the
// centre itself being temporarily dry across ALL of its weeks, by retrying
// the whole vehicle search against each postcode in the CSV list (each one
// resolves to a different fitting centre with its own independent
// inventory) until one has an enabled candidate anywhere in its dropdown.
//
// Redoes the full search per postcode (a fresh "towbars" page navigation
// resets the form, so earlier selections can't just be reused) - the
// vehicle's own fields (make/model/year/body type etc.) come from the data
// table so this isn't hardcoded to one specific vehicle, only the
// conventional element keys below are: "Postcode input", "Search towbars
// button", "Yes, this is my vehicle" and "Select towbar button" (the 1st
// recommended towbar is used every attempt) are expected to exist in the
// calling project's own mapping, the same convention the compound login
// step uses for login.json's keys. Needs a generous step timeout - each
// postcode attempt can itself take up to ~90s (this framework's own
// per-listbox default), and this tries several postcodes in turn.
When(/^I search for a vehicle with the details below, retrying with each postcode in "([^"]*)" until the "([^"]*)" listbox has an option with an enabled "([^"]*)" candidate:$/,
    { timeout: 600000 },
    async function (this: ScenarioWorld, postcodesCsv: string, weekListboxKey: ElementKey, candidateKey: ElementKey, table: DataTable) {
        const {
            screen: {page},
            globalConfig
        } = this;

        const vehicleFields = table.rowsHash();
        const postcodes = postcodesCsv.split(",").map((s) => s.trim()).filter(Boolean);

        for (const postcode of postcodes) {
            await navigateToPage(page, "towbars", globalConfig);

            for (const [fieldKey, value] of Object.entries(vehicleFields)) {
                const fieldTrigger = await resolveComboboxTrigger(page, getElementLocator(page, fieldKey, globalConfig));
                const listbox = page.locator("[role='listbox']:visible").last();
                await fieldTrigger.click();
                await listbox.locator("[role='option']").first().waitFor({ state: "visible", timeout: 15000 });
                await listbox.getByText(value, { exact: true }).click();
            }

            await page.fill(getElementLocator(page, "Postcode input", globalConfig), postcode);
            await page.click(getElementLocator(page, "Search towbars button", globalConfig));
            await page.click(getElementLocator(page, "Yes, this is my vehicle", globalConfig));
            await waitFor(() => new URL(page.url()).pathname.includes("/towbars/comparison"), { timeout: 20000 });

            await clickElementAtIndex(page, getElementLocator(page, "Select towbar button", globalConfig), 0, { force: true });
            await waitFor(() => new URL(page.url()).pathname.includes("/products/"), { timeout: 20000 });

            // Resolved here, not before the loop starts: getElementLocator
            // keys off the CURRENT page (via getCurrentPageId), and before
            // this first navigateToPage call above, that's still whatever
            // page the calling scenario's Background left off on (e.g.
            // towbar-comparison) - which has no "Fitting slot" mapping key,
            // silently resolving to a locator that matches nothing rather
            // than throwing (confirmed live: an 18-minute run that quietly
            // timed out on every week of every postcode because of this).
            const weekTrigger = await resolveComboboxTrigger(page, getElementLocator(page, weekListboxKey, globalConfig));
            const candidateIdentifier = getElementLocator(page, candidateKey, globalConfig);
            const found = await selectOptionWithEnabledCandidate(page, weekTrigger, candidateIdentifier);
            if (found) {
                return;
            }
        }

        throw new Error(`No postcode in "${postcodesCsv}" left an enabled "${candidateKey}" candidate for the "${weekListboxKey}" listbox, across any of its weeks.`);
    }
);