"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
// The currency picker is a header dropdown: click the toggle to reveal the
// GBP/EUR options, then click the requested one.
(0, _cucumber.When)(/^I switch the currency to "(GBP|EUR)"$/, async function (currency) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const toggleLocator = (0, _webElementHelper.getElementLocator)(page, "currency picker", globalConfig);
  await page.click(toggleLocator, {
    timeout: 15000
  });
  const optionLocator = (0, _webElementHelper.getElementLocator)(page, `${currency} currency option`, globalConfig);
  await page.waitForSelector(optionLocator, {
    state: "visible",
    timeout: 10000
  });
  await page.click(optionLocator, {
    timeout: 10000
  });
});