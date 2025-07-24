"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const result = await (0, _waitForBehaviour.waitFor)(async () => elementIdentifier, {
    state: "visible"
  });
  if (result) {
    await new Promise(resolve => setTimeout(resolve, 300));
    await (0, _htmlBehaviour.clickElement)(page, elementIdentifier);
  }
  return result;
});
(0, _cucumber.When)(/^I slowly click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const result = await (0, _waitForBehaviour.waitFor)(async () => elementIdentifier, {
    state: "visible"
  });
  if (result) {
    await new Promise(resolve => setTimeout(resolve, 6000));
    await (0, _htmlBehaviour.clickElement)(page, elementIdentifier);
  }
  return result;
});
(0, _cucumber.When)(/^I click on the "(\d+(?:st|nd|rd|th))" "([^"]+)" (?:button|link|element)$/, async function (elementPosition, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);

  // Extract number from "2nd", "3rd", "10th", etc.
  const index = Number(elementPosition.match(/\d+/)?.[0]) - 1;
  await (0, _waitForBehaviour.waitFor)(async () => {
    const result = await page.waitForSelector(elementIdentifier, {
      state: "visible"
    });
    if (result) {
      await (0, _htmlBehaviour.clickElementAtIndex)(page, elementIdentifier, index);
    }
    return result;
  });
});