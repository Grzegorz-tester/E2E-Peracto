"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
// Generates a disposable, collision-free product name/SKU (same "qa-<ts>"
// shape as form.ts's "unique value" step) and stashes it in globalVariables
// so a later step in the same scenario can confirm the exact value it typed
// really persisted, rather than just trusting a save succeeded - mirrors
// checkout.ts's guest-email stash/reuse pair.
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique product name$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const productName = `Velstar Test Product ${Date.now()}`;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, productName);
  this.globalVariables["product name"] = productName;
});
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique product SKU$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const productSku = `VEL-TEST-${Date.now()}`;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.enterValue)(page, elementIdentifier, productSku);
  this.globalVariables["product sku"] = productSku;
});
(0, _cucumber.Then)(/^the "([^"]*)" input field should have the stored product name$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const productName = this.globalVariables["product name"];
  if (!productName) {
    throw new Error(`No stored product name found - "I fill in the ... with a unique product name" must run first.`);
  }
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => (await (0, _htmlBehaviour.getValue)(page, elementIdentifier)) === productName, {
    expected: `"${elementKey}" (${elementIdentifier}) to have the stored product name "${productName}"`,
    describeActual: async () => `value was "${(await (0, _htmlBehaviour.getValue)(page, elementIdentifier).catch(() => null)) ?? "(could not read value)"}"`
  });
});
(0, _cucumber.Then)(/^the "([^"]*)" input field should have the stored product SKU$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const productSku = this.globalVariables["product sku"];
  if (!productSku) {
    throw new Error(`No stored product SKU found - "I fill in the ... with a unique product SKU" must run first.`);
  }
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => (await (0, _htmlBehaviour.getValue)(page, elementIdentifier)) === productSku, {
    expected: `"${elementKey}" (${elementIdentifier}) to have the stored product SKU "${productSku}"`,
    describeActual: async () => `value was "${(await (0, _htmlBehaviour.getValue)(page, elementIdentifier).catch(() => null)) ?? "(could not read value)"}"`
  });
});