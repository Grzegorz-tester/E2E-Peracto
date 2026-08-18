"use strict";

var _cucumber = require("@cucumber/cucumber");
var _test = require("@playwright/test");
var _webElementHelper = require("../../support-functions/web-element-helper");
// Generic single-open accordion check: the first trigger starts expanded,
// opening the second collapses the first. Reusable by any project with an
// aria-expanded-driven accordion - elementKey should resolve to ALL of the
// accordion's own triggers (not scoped to just one).
(0, _cucumber.Then)(/^the "([^"]*)" accordion should allow only one section open at a time$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const triggerSelector = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const triggers = page.locator(triggerSelector);
  await (0, _test.expect)(triggers.nth(0)).toHaveAttribute("aria-expanded", "true");
  await (0, _test.expect)(triggers.nth(1)).toHaveAttribute("aria-expanded", "false");
  // A trigger far enough down a long accordion (e.g. an FAQ list with
  // many entries) can otherwise sit outside Playwright's own
  // auto-scroll margin - scrolling it into view explicitly first avoids
  // a click landing without effect.
  await triggers.nth(1).scrollIntoViewIfNeeded();
  await triggers.nth(1).click();
  await (0, _test.expect)(triggers.nth(1)).toHaveAttribute("aria-expanded", "true");
  await (0, _test.expect)(triggers.nth(0)).toHaveAttribute("aria-expanded", "false");
});