"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _test = require("@playwright/test");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
// the element should contain the text ( text content of the element)
(0, _cucumber.Then)(/^the "([^"]*)" should( not)? contain the text ["']([^"']+)["']$/, async function (elementKey, negate, expectedElementText) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const elementText = await page.textContent(elementIdentifier);
    return elementText?.includes(expectedElementText) === !negate;
  });
});

// the ( element ) should equal text ( text content of the element)
(0, _cucumber.Then)(/^the "([^"]*)" should( not)? equal text "([^"]*)"$/, async function (elementKey, negate, expectedElementText) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const elementText = await page.textContent(elementIdentifier);
    return elementText === expectedElementText === !negate;
  });
});

// the ( element ) should equal value ( value of the element)
(0, _cucumber.Then)(/^the "([^"]*)" should( not)? equal the value "([^"]*)"$/, async function (elementKey, negate, elementValue) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const elementAttribute = await (0, _htmlBehaviour.getValue)(page, elementIdentifier);
    return elementAttribute === elementValue === !negate;
  });
});

// he should be presented with a ( message locator ) ( text content of the message )
(0, _cucumber.Then)(/^I should be presented with a "([^"]*)" "([^"]*)"$/, async function (elementKey, expectedElementText) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const elementText = await page.textContent(elementIdentifier);
  (0, _test.expect)(elementText).toContain(expectedElementText);
});

//the ( container ) should contain ( amount of items ) ( item )
// Then(/^the "([^"]*)" should contain "([^"]*)" "([^"]*)"$/, async function (
//     containerElementKey: ElementKey,
//     amount: number,
//     itemElementKey: ElementKey) {
//
// });

(0, _cucumber.Then)(/^the "([0-9]+th|[0-9]+st|[0-9]+nd|[0-9]+rd)" "([^"]*)" should( not)? contain the text "(.*)"$/, async function (elementPosition, elementKey, negate, expectedElementText) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  console.log(`the ${elementPosition} ${elementKey} should ${negate ? "not " : ""}contain the text ${expectedElementText}`);
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const index = Number(elementPosition.match(/\d/g)?.join("")) - 1;
  await (0, _waitForBehaviour.waitFor)(async () => {
    const elementText = await page.textContent(`${elementIdentifier}>>nth=${index}`);
    return elementText?.includes(expectedElementText) === !negate;
  });
});