"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
// NOT a site bug - genuinely functional for a real user, but confirmed
// flaky specifically under automation: a plain Playwright .click() (even
// with a delay) consistently fails to close this drawer. A real
// mousedown-PAUSE-mouseup gesture is required instead, and even that can
// intermittently fail in the exact same conditions - retrying the whole
// gesture rides out that flakiness rather than chasing a fully
// deterministic fix that doesn't exist. Reusable by any project with a
// similarly gesture-sensitive close control - point elementKey at that
// project's own mapping for the two keys below.
(0, _cucumber.When)(/^I close the "([^"]*)" using a mouse-hold gesture on the "([^"]*)"$/, async function (panelKey, closeButtonKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const panelSelector = (0, _webElementHelper.getElementLocator)(page, panelKey, globalConfig);
  const closeButtonSelector = (0, _webElementHelper.getElementLocator)(page, closeButtonKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    // Settle wait for the panel's own open/slide-in transition.
    await page.waitForTimeout(600);
    const box = await page.locator(closeButtonSelector).boundingBox();
    if (!box) return false;
    await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
    await page.mouse.down();
    await page.waitForTimeout(150);
    await page.mouse.up();
    return page.locator(panelSelector).waitFor({
      state: "hidden",
      timeout: 3000
    }).then(() => true).catch(() => false);
  }, {
    timeout: 20000,
    wait: 200
  });
});
(0, _cucumber.When)(/^I submit the search drawer for "([^"]*)"$/, async function (query) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const inputSelector = (0, _webElementHelper.getElementLocator)(page, "search drawer input", globalConfig);
  await page.press(inputSelector, "Enter");
  await (0, _waitForBehaviour.waitFor)(() => page.url().includes(`/search?q=${encodeURIComponent(query)}`));
});