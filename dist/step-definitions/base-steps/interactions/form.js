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
(0, _cucumber.When)(/^I select the "([^"]*)" option from the "([^"]*)" listbox$/, async function (option, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const resolved = page.locator(elementIdentifier);
  const isComboboxItself = (await resolved.getAttribute("role").catch(() => null)) === "combobox";
  const trigger = isComboboxItself ? resolved : resolved.locator("button[role='combobox']");
  await trigger.waitFor({
    state: "visible",
    timeout: 15000
  });

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
  const openedFirstTry = await listOptions.first().waitFor({
    state: "visible",
    timeout: 5000
  }).then(() => true).catch(() => false);
  if (!openedFirstTry) {
    await trigger.click();
    await listOptions.first().waitFor({
      state: "visible",
      timeout: 15000
    });
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
  await listbox.getByText(option, {
    exact: true
  }).click();
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
(0, _cucumber.When)(/^I select an option from the "([^"]*)" listbox with an enabled "([^"]*)" candidate$/, {
  timeout: 90000
}, async function (listboxKey, candidateKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, listboxKey, globalConfig);
  const candidateIdentifier = (0, _webElementHelper.getElementLocator)(page, candidateKey, globalConfig);
  const resolved = page.locator(elementIdentifier);
  const isComboboxItself = (await resolved.getAttribute("role").catch(() => null)) === "combobox";
  const trigger = isComboboxItself ? resolved : resolved.locator("button[role='combobox']");
  await trigger.waitFor({
    state: "visible",
    timeout: 15000
  });

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
    await trigger.click({
      force: true
    });
    const openedFirstTry = await listOptions.first().waitFor({
      state: "visible",
      timeout: 5000
    }).then(() => true).catch(() => false);
    if (!openedFirstTry) {
      await trigger.click({
        force: true
      });
      await listOptions.first().waitFor({
        state: "visible",
        timeout: 15000
      });
    }
    return listOptions;
  };
  const optionCount = await (await openListbox()).count();
  for (let i = optionCount - 1; i >= 0; i--) {
    const listOptions = await openListbox();
    await listOptions.nth(i).click();
    const candidates = page.locator(candidateIdentifier);
    await candidates.first().waitFor({
      state: "visible",
      timeout: 15000
    });
    const candidateCount = await candidates.count();
    for (let c = 0; c < candidateCount; c++) {
      if (await candidates.nth(c).isEnabled()) {
        return;
      }
    }
  }
  throw new Error(`No option in the "${listboxKey}" listbox left an enabled "${candidateKey}" candidate.`);
});