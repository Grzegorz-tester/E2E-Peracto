"use strict";

var _cucumber = require("@cucumber/cucumber");
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
  await page.click(categoryLink);
});