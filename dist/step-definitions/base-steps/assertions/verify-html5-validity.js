"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
// Some forms (newsletter sign-up, warranty lookup, etc.) have NO custom
// client-side validation UI at all - they're a native <input required> or
// <input type="email">, so an empty/malformed submission is blocked
// entirely by the browser's own validity state, with no rendered error
// message in the DOM to assert against instead. Reusable by any project
// with the same native-validation pattern - just point elementKey at that
// project's own input mapping.
(0, _cucumber.Then)(/^the "([^"]*)" input should be rejected as (empty|invalid)$/, async function (elementKey, kind) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const validity = await page.$eval(elementIdentifier, el => ({
    valid: el.validity.valid,
    valueMissing: el.validity.valueMissing,
    typeMismatch: el.validity.typeMismatch
  }));
  if (validity.valid) {
    throw new Error(`Expected "${elementKey}" to be rejected by native validation, but it reported valid.`);
  }
  if (kind === "empty" && !validity.valueMissing) {
    throw new Error(`Expected "${elementKey}" to be rejected for being empty (valueMissing), got ${JSON.stringify(validity)}.`);
  }
  if (kind === "invalid" && !validity.typeMismatch) {
    throw new Error(`Expected "${elementKey}" to be rejected for being malformed (typeMismatch), got ${JSON.stringify(validity)}.`);
  }
});