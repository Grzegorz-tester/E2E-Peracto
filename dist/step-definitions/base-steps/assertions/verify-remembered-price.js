"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _priceHelper = require("../../support-functions/price-helper");
// For carrying a price from one page to a later one when the two pages
// format it differently - confirmed live on Andy Thornton's checkout
// (2026-09-30): the review step's summary reads "£144.00(inc VAT)" while the
// thank-you page reads "£144.00", so a plain text comparison can't work, and
// the amount itself depends on the delivery address so it can't be
// hard-coded either. Compares the parsed numbers, so it's format-agnostic
// across storefronts (see price-helper.ts).
(0, _cucumber.When)(/^I remember the price in "([^"]*)" as "([^"]*)"$/, async function (elementKey, variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const text = await page.textContent(elementIdentifier, {
    timeout: 15000
  });
  this.globalVariables[variableName] = String((0, _priceHelper.parsePrice)(text));
});
(0, _cucumber.Then)(/^the price in "([^"]*)" should equal the remembered "([^"]*)"$/, async function (elementKey, variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const remembered = this.globalVariables[variableName];
  if (remembered === undefined) {
    throw new Error(`No remembered price found for "${variableName}" - "I remember the price in ... as ..." must run first.`);
  }
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  let lastText = null;
  await (0, _waitForBehaviour.waitFor)(async () => {
    lastText = await page.textContent(elementIdentifier, {
      timeout: 1000
    }).catch(() => null);
    if (!lastText) return false;
    return Math.abs((0, _priceHelper.parsePrice)(lastText) - Number(remembered)) < 0.005;
  }, {
    expected: `"${elementKey}" (${elementIdentifier}) to show the remembered price ${Number(remembered).toFixed(2)}`,
    describeActual: async () => `text was "${lastText?.trim() ?? "(could not read text)"}"`
  });
});