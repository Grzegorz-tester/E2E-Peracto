"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
// Sources the value from users.json/env vars instead of literal Gherkin text,
// so real credentials never need to be hardcoded in a .feature file (e.g. to
// deliberately test a wrong-password login while still using a real email).
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with the "([^"]*)" user's (email|password)$/, async function (elementKey, userType, field) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const user = globalConfig.usersConfig[userType.trim().toLowerCase()];
  const value = user?.[field];
  if (!value) {
    throw new Error(`Missing "${field}" for user type "${userType}". Check your users.json and env vars.`);
  }
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);

  // waitForSelector already throws (rather than returning falsy) on
  // timeout, so wrapping it in waitFor's retry loop below never actually
  // retries - the loop's own error message never fires. Give it an
  // explicit timeout with headroom under SCRIPT_TIMEOUT instead.
  await page.waitForSelector(elementIdentifier, {
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, value);
});

// For a field that just needs to be non-empty and collision-free (e.g. a
// warranty lookup's serial number), rather than a real email address - see
// "... with a unique guest email" above for the email-shaped equivalent.
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique value$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, `qa-${Date.now()}`);
});
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with "([^"]*)"$/, async function (elementKey, inputText) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, inputText);
});

// The Algolia search-results autocomplete is debounced and re-renders as
// the query resolves. Without this, a fast test can assert "search results
// displayed" and click the "first search result" while it's still showing
// the previous/default result set, landing on the wrong product instead of
// a "<term>"-matching one.
(0, _cucumber.When)(/^I wait for the search results to update$/, async function () {
  await new Promise(resolve => setTimeout(resolve, 1500));
});

// For a search box (or any input) whose submit action is pressing Enter
// rather than clicking a separate button - e.g. Watco's header search,
// which navigates straight to a /search results page on Enter.
(0, _cucumber.When)(/^I press Enter in the "([^"]*)" input field$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
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
(0, _cucumber.When)(/^I select the "([^"]*)" option from the "([^"]*)" dropdown$/, async function (option, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  const ordinalMatch = option.match(/^(\d+)(?:st|nd|rd|th)$/);
  if (ordinalMatch) {
    await page.focus(elementIdentifier);
    await page.selectOption(elementIdentifier, {
      index: Number(ordinalMatch[1]) - 1
    });
  } else {
    await (0, _htmlBehaviour.selectDropdownOption)(page, elementIdentifier, option);
  }
});