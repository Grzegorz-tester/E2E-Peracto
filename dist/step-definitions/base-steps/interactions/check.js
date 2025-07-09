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
  await (0, _waitForBehaviour.waitFor)(async () => {
    const result = await page.waitForSelector(elementIdentifier, {
      state: "visible"
    });
    if (result) {
      await (0, _htmlBehaviour.checkElement)(page, elementIdentifier);
    }
    return result;
  });
});