"use strict";

var _cucumber = require("@cucumber/cucumber");
var _test = require("@playwright/test");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
// Whether "next" should be enabled depends on whether the carousel's own
// content actually overflows at the CURRENT viewport - at wide viewports all
// features can fit with no overflow, and both buttons being disabled is the
// correct state there, not a bug. Checks the real scroll state first and
// asserts whichever behaviour is actually correct for it. The prev/next
// buttons carry no testid/id/aria-label anywhere on this component - only
// their position relative to the heading distinguishes them - so this
// reaches into locator("..") parent traversal directly rather than a static
// mapping entry, the same class of exception as an iframe frameLocator
// elsewhere in this framework.
(0, _cucumber.Then)(/^the product features carousel navigation should match the current viewport's overflow state$/, async function () {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const headingSelector = (0, _webElementHelper.getElementLocator)(page, "product features carousel heading", globalConfig);
  const heading = page.locator(headingSelector);
  const section = heading.locator("..").locator("..");
  const prevButton = heading.locator("..").getByRole("button").first();
  const nextButton = heading.locator("..").getByRole("button").last();
  const getScrollState = () => section.evaluate(el => {
    const scrollable = el.querySelector('[class*="overflow"]');
    return {
      scrollLeft: scrollable?.scrollLeft ?? 0,
      hasOverflow: (scrollable?.scrollWidth ?? 0) > (scrollable?.clientWidth ?? 0)
    };
  });

  // Settle wait - clicks were observed to silently no-op without it.
  await page.waitForTimeout(800);
  const {
    hasOverflow
  } = await getScrollState();
  if (!hasOverflow) {
    await (0, _test.expect)(prevButton).toBeDisabled();
    await (0, _test.expect)(nextButton).toBeDisabled();
    return;
  }
  await (0, _test.expect)(prevButton).toBeDisabled();
  await (0, _test.expect)(nextButton).toBeEnabled();
  await nextButton.click({
    delay: 100
  });
  await (0, _waitForBehaviour.waitFor)(async () => {
    const {
      scrollLeft
    } = await getScrollState();
    return scrollLeft > 0;
  }, {
    timeout: 10000,
    wait: 500
  });
  await (0, _test.expect)(prevButton).toBeEnabled();
});