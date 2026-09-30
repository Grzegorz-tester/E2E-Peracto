"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
// Same "Velstar Test <Entity> <ts>" identifiability convention as
// product-admin.ts's "unique product name" - so an orphaned Form/Form
// Field left behind by a failed delete step (as happened with Lamona's
// leftover "Velstar Test Product" rows) is immediately recognisable as our
// own disposable test data in a client's real admin, not guessed at later.
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique form label$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const formLabel = `Velstar Test Form ${Date.now()}`;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, formLabel);
  this.globalVariables["form label"] = formLabel;
});
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique form field label$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const formFieldLabel = `Velstar Test Field ${Date.now()}`;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, formFieldLabel);
  this.globalVariables["form field label"] = formFieldLabel;
});