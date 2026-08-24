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

// For any page whose client state loads in asynchronously after the initial
// render - confirmed live on MIPA's basket (an id populated after landing on
// /basket, racing a fast automated click into sending a request against it
// before it's set - "PUT /baskets/undefined", a real backend 500) and
// suspected on its Register form (shifting symptoms - empty fields, a
// button stuck disabled - consistent with the same class of "acted before
// state was ready" race). A real user never hits this: reading the page and
// moving the mouse already takes longer than the load. "networkidle" is the
// actual condition worth waiting for here (the page's own background
// fetches settling), not a guessed fixed delay - a flat 2000ms delay tried
// first still let the race through occasionally. Bounded and best-effort
// (a tracker/ad request that never goes idle shouldn't hang the step).
// Reusable by any project/page with a similar race.
(0, _cucumber.When)(/^I wait for the page to settle$/, async function () {
  const {
    screen: {
      page
    }
  } = this;
  await page.waitForLoadState("networkidle", {
    timeout: 8000
  }).catch(() => {});
  await new Promise(resolve => setTimeout(resolve, 1000));
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