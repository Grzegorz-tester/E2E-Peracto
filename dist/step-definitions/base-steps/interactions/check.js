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
  });
});