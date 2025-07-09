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
(0, _cucumber.When)(/^I click the "([0-9]+th|[0-9]+st|[0-9]+nd|[0-9]+rd)" "([^"]*)" (?:button|link|element)$/, async function (elementPosition, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;

  // Get the element locator
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);

  // Extract the numeric part of the position and convert to zero-based index
  const pageIndex = Number(elementPosition.match(/\d+/)?.[0]) - 1;

  // Wait for the element to be visible and click it
  await (0, _waitForBehaviour.waitFor)(async () => {
    const result = await page.waitForSelector(elementIdentifier, {
      state: 'visible'
    });
    if (result) {
      await (0, _htmlBehaviour.clickElementAtIndex)(page, elementIdentifier, pageIndex);
    }
    return result;
  });
});