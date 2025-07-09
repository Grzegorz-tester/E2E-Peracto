"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
(0, _cucumber.Then)(/^the "([^"]*)" should\s*(not)?\s*be displayed$/, async function (elementKey, negate) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const isElementVisible = (await page.$(elementIdentifier)) != null;
    return isElementVisible === !negate;
  });
});

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
(0, _cucumber.Then)(/^the "([^"]*)" should\s*(not)?\s*be enabled$/, async function (elementKey, negate) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const isElementEnabled = await page.isEnabled(elementIdentifier);
    return isElementEnabled === !negate;
  });
});
(0, _cucumber.Then)(/^I should( not)? see "([^"]*)" "([^"]*)" displayed$/, async function (negate, count, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const element = await page.$$(elementIdentifier);
    return count === String(element.length) === !negate;
  });
});