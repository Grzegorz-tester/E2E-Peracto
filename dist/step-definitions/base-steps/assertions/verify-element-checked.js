"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
(0, _cucumber.Then)(/^the "([^"]*)" radio button should( not)? be checked$/, async function (elementKey, negate) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  console.log(`the ${elementKey} radio button should ${negate ? 'not ' : ''}be checked`);
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const isElementVisible = await page.isChecked(elementIdentifier);
    return isElementVisible === !negate;
  }, {
    expected: `"${elementKey}" (${elementIdentifier}) radio button to ${negate ? "not be" : "be"} checked`,
    describeActual: async () => {
      const isChecked = await page.isChecked(elementIdentifier).catch(() => undefined);
      const state = isChecked === undefined ? "could not read its checked state" : isChecked ? "checked" : "not checked";
      return `${await (0, _webElementHelper.describeElement)(page, elementIdentifier)}, ${state}`;
    }
  });
});