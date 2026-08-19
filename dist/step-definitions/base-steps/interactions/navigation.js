"use strict";

var _cucumber = require("@cucumber/cucumber");
var _navigationBehaviour = require("../../support-functions/navigation-behaviour");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
(0, _cucumber.Given)(/^I am on the "([^"]*)" page$/, async function (pageId) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  await (0, _navigationBehaviour.navigateToPage)(page, pageId, globalConfig);
  await (0, _waitForBehaviour.waitFor)(() => (0, _navigationBehaviour.currentPathMatchesPageId)(page, pageId, globalConfig));
});

// For asserting server-persisted state survives a fresh page load, rather
// than a client-side value that would pass even if nothing was actually
// saved (e.g. Watco's account-profile VAT field).
(0, _cucumber.When)(/^I reload the page$/, async function () {
  const {
    screen: {
      page
    }
  } = this;
  await page.reload({
    waitUntil: "domcontentloaded",
    timeout: 30000
  });
});

// Cucumber's default Playwright viewport (1280x720) is already above most
// sites' "lg" breakpoint, so mobile-only nav (e.g. KOOL's hamburger menu,
// which is "lg:hidden") never renders without explicitly narrowing the
// viewport first.
(0, _cucumber.When)(/^I resize the browser to a "(mobile|desktop)" viewport$/, async function (size) {
  const {
    screen: {
      page
    }
  } = this;
  const viewport = size === "mobile" ? {
    width: 390,
    height: 844
  } : {
    width: 1280,
    height: 720
  };
  await page.setViewportSize(viewport);
});

// Confirmed live (KOOL mobile nav drawer): clicking the dialog's own backdrop
// closes it via a mousedown handler, but the same click's mouseup/click event
// then bubbles through to whatever link sits underneath at that screen
// position once the backdrop is gone - a click-through, not a real second
// interaction. Escape avoids that hazard entirely and is the standard way to
// dismiss a HeadlessUI dialog.
(0, _cucumber.When)(/^I press the Escape key$/, async function () {
  const {
    screen: {
      page
    }
  } = this;
  await page.keyboard.press("Escape");
});