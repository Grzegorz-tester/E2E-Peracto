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

// Confirmed live (Keylite_ADMIN_RELEASE, 2026-09-16): a plain
// "VEL-TEST-<Date.now()>" SKU is 22 characters, and Peracto Admin's
// Product Variant Save rejects any SKU over 20 with a 422 ("Products
// 'Sku' exceeds the character limit of 20.") - shown as a real error
// toast, not silence, but easy to miss because it renders alongside (and
// looks like) any other transient toast if a scenario isn't specifically
// asserting on it. Truncating to the last 8 digits of Date.now() keeps
// this comfortably under 20 chars everywhere while remaining unique for
// any realistic test run (repeats only every ~27.7 hours).
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique product SKU$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const productSku = `VEL-TEST-${Date.now().toString().slice(-8)}`;
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