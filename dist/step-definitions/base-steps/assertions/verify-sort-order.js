"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _priceHelper = require("../../support-functions/price-helper");
// Generic across any project: elementKey should resolve to every price on
// the page in visual/DOM order (e.g. a PLP's per-card "from" price), scoped
// under whatever container config already keeps clear of unrelated
// merchandising blocks (see plp.json's "#results-container" comment). Polls
// rather than reading once, since sorting a Bloomreach/Algolia-driven grid
// re-issues a query and the new order can render a moment after the sort
// control itself reports selected - but a genuinely broken sort never
// settles, so this still fails loud once the timeout is exhausted.
(0, _cucumber.Then)(/^the "([^"]*)" prices should be sorted in "(ascending|descending)" order$/, async function (elementKey, direction) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const ascending = direction === "ascending";
  let priceTexts = [];
  let breaks = [];
  await (0, _waitForBehaviour.waitFor)(async () => {
    priceTexts = await page.locator(elementIdentifier).allTextContents();
    if (priceTexts.length < 2) return false;
    const prices = priceTexts.map(_priceHelper.parsePrice);
    breaks = [];
    for (let i = 1; i < prices.length; i++) {
      const inOrder = ascending ? prices[i] >= prices[i - 1] : prices[i] <= prices[i - 1];
      if (!inOrder) breaks.push(i);
    }
    return breaks.length === 0;
  }, {
    timeout: 15000,
    wait: 500,
    expected: `every "${elementKey}" (${elementIdentifier}) price to be sorted in ${direction} order`,
    describeActual: async () => {
      const trimmed = priceTexts.map(text => text.trim());
      if (trimmed.length < 2) return `only found ${trimmed.length} matching element(s): ${JSON.stringify(trimmed)}`;
      const breakDetail = breaks.map(i => `position ${i} ("${trimmed[i - 1]}" -> "${trimmed[i]}")`).join(", ");
      return `sequence was ${JSON.stringify(trimmed)} - order broke at ${breakDetail}`;
    }
  });
});