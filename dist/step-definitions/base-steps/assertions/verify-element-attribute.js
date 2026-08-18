"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _test = require("@playwright/test");
// For a raw HTML attribute (placeholder, data-*, etc.) rather than an
// element's text/value - e.g. asserting a field's placeholder copy, or a
// header link's live item-count via a data-* attribute.
(0, _cucumber.Then)(/^the "([^"]*)" should have attribute "([^"]*)" with value "([^"]*)"$/, async function (elementKey, attribute, expectedValue) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _test.expect)(page.locator(elementIdentifier)).toHaveAttribute(attribute, expectedValue, {
    timeout: 15000
  });
});

// For a CSS-class-driven state a site toggles via JS rather than a
// dedicated data-testid/aria attribute - e.g. Watco's ".is-invalid" on a
// rejected VAT number, or ".js-vat-apply-group--dirty" on an edited-but-
// not-yet-applied field. Matches by substring (classList contains, not
// className equals) since real elements carry several classes at once.
(0, _cucumber.Then)(/^the "([^"]*)" should( not)? have class "([^"]*)"$/, async function (elementKey, negate, className) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const locator = page.locator(elementIdentifier);
  if (negate) {
    await (0, _test.expect)(locator).not.toHaveClass(new RegExp(className), {
      timeout: 15000
    });
  } else {
    await (0, _test.expect)(locator).toHaveClass(new RegExp(className), {
      timeout: 15000
    });
  }
});