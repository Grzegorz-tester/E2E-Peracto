import {When} from "@cucumber/cucumber";
import {ElementKey} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {enterValue, selectDropdownOption} from "../../support-functions/html-behaviour";
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