"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
// For a list page where "no rows" can mean two very different things: a
// genuine empty result set (the site's own "no results" message renders) or
// the data silently failing to load (a heading/shell renders, but nothing
// underneath it - e.g. a 500 fetching the list). Checking only that a
// heading is present can't tell these apart; this requires ACTUAL content
// (either real rows or the confirmed-genuine empty-state message), so a
// broken/empty-by-accident page still fails.
(0, _cucumber.Then)(/^the "([^"]*)" should be displayed or the "([^"]*)" should be displayed$/, async function (firstElementKey, secondElementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const firstIdentifier = (0, _webElementHelper.getElementLocator)(page, firstElementKey, globalConfig);
  const secondIdentifier = (0, _webElementHelper.getElementLocator)(page, secondElementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const firstVisible = (await page.$(firstIdentifier)) != null;
    const secondVisible = (await page.$(secondIdentifier)) != null;
    return firstVisible || secondVisible;
  });
});

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
(0, _cucumber.Then)(/^the "([^"]*)" should\s*(not)?\s*be displayed$/, async function (elementKey, negate) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const isElementVisible = (await page.$(elementIdentifier)) != null;
    return isElementVisible === !negate;
  });
});

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
(0, _cucumber.Then)(/^the "([^"]*)" should\s*(not)?\s*be enabled$/, async function (elementKey, negate) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const isElementEnabled = await page.isEnabled(elementIdentifier);
    return isElementEnabled === !negate;
  });
});
(0, _cucumber.Then)(/^I should( not)? see "([^"]*)" "([^"]*)" displayed$/, async function (negate, count, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const element = await page.$$(elementIdentifier);
    return count === String(element.length) === !negate;
  });
});

// Remembers a live count instead of a hardcoded number, so tests against
// content that changes over time (product catalogues, search results) stay
// correct rather than asserting a snapshot-in-time total.
(0, _cucumber.When)(/^I remember the number of "([^"]*)" elements as "([^"]*)"$/, async function (elementKey, variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const elements = await page.$$(elementIdentifier);
  this.globalVariables[variableName] = String(elements.length);
});
(0, _cucumber.Then)(/^the number of "([^"]*)" elements should (equal|be fewer than|be more than) the remembered "([^"]*)"$/, async function (elementKey, comparison, variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const remembered = this.globalVariables[variableName];
  if (remembered === undefined) {
    throw new Error(`No remembered count found for "${variableName}" - "I remember the number of ... elements as ..." must run first.`);
  }
  const rememberedCount = Number(remembered);
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const currentCount = (await page.$$(elementIdentifier)).length;
    if (comparison === "equal") return currentCount === rememberedCount;
    if (comparison === "be fewer than") return currentCount < rememberedCount;
    return currentCount > rememberedCount;
  });
});