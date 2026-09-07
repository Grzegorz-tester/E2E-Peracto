"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
(0, _cucumber.When)(/^I check the "([^"]*)"$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);

  // waitForSelector already throws (rather than returning falsy) on
  // timeout, so wrapping it in waitFor's retry loop below never actually
  // retries - the loop's own error message never fires. Give it an
  // explicit timeout with headroom under SCRIPT_TIMEOUT instead.
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.checkElement)(page, elementIdentifier);
});

// The uncheck counterpart to "I check the ..." above - for a real toggle
// (e.g. Russells' header VAT-inclusive/exclusive switch) that a scenario
// needs to set to a KNOWN state in either direction, not just turn on.
// page.uncheck() is idempotent (a no-op if already unchecked), the same
// property "I check" already relies on. Waits for "attached" rather than
// "visible" - like "I ensure the ... checkbox is checked" below, a real
// toggle's underlying <input type="checkbox"> is often visually hidden
// behind custom switch styling (confirmed on Russells' VAT toggle, whose
// visible clickable element is a separate wrapping "switch" component) -
// uncheckElement's own force:true already tolerates that for the actual
// action, so requiring "visible" here first would just fail before ever
// reaching it.
(0, _cucumber.When)(/^I uncheck the "([^"]*)"$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "attached",
    timeout: 15000
  });
  await (0, _htmlBehaviour.uncheckElement)(page, elementIdentifier);
});

// For a checkbox whose native <input> is deliberately visually hidden
// behind custom styling (a wrapping <label> plus a decorative <span> that's
// what actually renders) - confirmed live on MIPA Admin's "Index Product"
// checkbox, unlike Carbon Admin's plain visible one for the same field
// despite both running the same underlying Peracto Admin product (see
// CLAUDE.md). The plain "I check" step above deliberately requires
// "visible" before acting, which a hidden-but-real input never satisfies -
// this reads/sets checked state directly via the DOM instead, and skips
// the click entirely if the box already reports checked (confirmed live:
// MIPA's defaults to checked already), rather than blindly clicking and
// risking toggling it OFF.
(0, _cucumber.When)(/^I ensure the "([^"]*)" checkbox is checked$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "attached",
    timeout: 15000
  });
  const isChecked = await page.isChecked(elementIdentifier);
  if (!isChecked) {
    await (0, _htmlBehaviour.checkElement)(page, elementIdentifier);
  }
});

// For a checkbox that doesn't always register as checked on the first
// click (a real, documented site quirk on some projects) - retries the
// click itself, not just the wait, until the checkbox genuinely reports
// checked. page.check() itself THROWS (rather than returning falsy) when a
// click doesn't change the checkbox's state - left uncaught, that exception
// would abort this loop on its very first attempt instead of retrying, the
// same class of bug already documented on the plain "I check" step above.
(0, _cucumber.When)(/^I check the "([^"]*)", retrying until it is checked$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    try {
      await (0, _htmlBehaviour.checkElement)(page, elementIdentifier);
    } catch {
      // Swallowed - a failed click attempt just means "not checked
      // yet", which the isChecked() check below already reports.
    }
    return page.isChecked(elementIdentifier);
  }, {
    expected: `"${elementKey}" (${elementIdentifier}) to become checked`,
    describeActual: () => (0, _webElementHelper.describeElement)(page, elementIdentifier)
  });
});

// Same reappearing-overlay problem already solved for clicks (see click.ts's
// "... dismissing the X if it interferes" steps) but for a checkbox -
// confirmed live on Insinkerator EU's guest checkout billing page: the
// OneTrust cookie banner reappeared directly over the "same as delivery"
// checkbox, and checkElement's own force:true click landed on the banner
// instead (six consecutive retries all reported "Clicking the checkbox did
// not change its state" with identical unchanged DOM). force:true only
// skips Playwright's own actionability checks, not the browser's native
// hit-testing, so a covering overlay still wins - deliberately NOT using
// checkElement/force here; a plain (non-forced) page.check() correctly
// waits out the overlay via Playwright's real actionability check instead,
// with the dismiss-and-retry loop as a second line of defence for when the
// banner is already gone by the time this fires but reappears again before
// the next retry.
(0, _cucumber.When)(/^I check the "([^"]*)", dismissing the "([^"]*)" if it interferes, retrying until it is checked$/, {
  timeout: 45000
}, async function (elementKey, dismissButtonKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const dismissButtonIdentifier = (0, _webElementHelper.getElementLocator)(page, dismissButtonKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const dismissButtonVisible = await page.locator(dismissButtonIdentifier).isVisible().catch(() => false);
    if (dismissButtonVisible) {
      await page.locator(dismissButtonIdentifier).click({
        force: true
      }).catch(() => {});
      await page.locator(dismissButtonIdentifier).waitFor({
        state: "hidden",
        timeout: 4000
      }).catch(() => {});
    }
    try {
      await page.check(elementIdentifier, {
        timeout: 8000
      });
    } catch {
      // Swallowed - a failed check attempt just means "not checked
      // yet", which the isChecked() check below already reports.
    }
    return page.isChecked(elementIdentifier);
  }, {
    timeout: 30000,
    wait: 500,
    expected: `"${elementKey}" (${elementIdentifier}) to become checked`,
    describeActual: () => (0, _webElementHelper.describeElement)(page, elementIdentifier)
  });
});