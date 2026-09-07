"use strict";

var _cucumber = require("@cucumber/cucumber");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
// Category links in the nav drawer are numbered/anonymous testids, only
// distinguishable by their visible text - mirrors
// InsinkeratorEuHomePage.chooseMenuCategory(). Opening the menu itself is a
// plain, reusable click (see the "Menu" key in common mappings); this step
// only covers the part that can't be expressed as a static elementKey,
// since the category name is a runtime parameter.
(0, _cucumber.When)(/^I choose the "([^"]*)" category from the menu$/, async function (category) {
  const {
    screen: {
      page
    }
  } = this;
  const categoryLink = `[data-testid^="navigation-drawer-sheet__current-tier-link-"]:has-text("${category}")`;
  await page.waitForSelector(categoryLink, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.clickElement)(page, categoryLink);
});

// For a category "hub" page's sub-category tiles, which carry no testid of
// their own - only a stable href (e.g. /category/general-parts-pto-driveline-components) -
// VERIFIED live on Russells (staging, 2026-07-31). The slug is a runtime
// parameter (which sub-category tile varies per hub page), so this can't be
// a static elementKey the way most clicks in this framework are; reusable
// by any project with the same "hub page links to /category/<slug>" shape.
(0, _cucumber.When)(/^I click on the sub-category tile for "([^"]*)"$/, async function (categorySlug) {
  const {
    screen: {
      page
    }
  } = this;
  const tile = page.locator(`a[href="/category/${categorySlug}"]`).first();
  await tile.waitFor({
    state: "visible",
    timeout: 30000
  });
  await tile.click();
});