"use strict";

var _cucumber = require("@cucumber/cucumber");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _webElementHelper = require("../../support-functions/web-element-helper");
const parsePrice = text => {
  const match = text?.match(/([\d.,]+)\s*€/);
  return match ? parseFloat(match[1].replace(/\./g, "").replace(",", ".")) : 0;
};

// Derives the expected total from the CURRENT unit price rather than a
// hardcoded value, so this keeps working if the product's price ever
// changes - a literal-value assertion would need updating by hand whenever
// that happens, and silently drift from meaningless (no longer possible to
// tell "feature broke" from "price changed") in the meantime. Also immune
// to exact-text-formatting gotchas (e.g. a non-breaking space before the
// currency symbol) since it parses to a number rather than string-matching
// the raw text. Reads "quantity input" / "quantity plus" / "quantity
// minus" / "basket total" from the current page's own element mappings,
// same as every other step in this framework - any project can reuse this
// step by defining those four keys in its own basket mapping file.
(0, _cucumber.When)(/^I (increment|decrement) the basket quantity and the total should update correctly$/, async function (direction) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const quantityInput = (0, _webElementHelper.getElementLocator)(page, "quantity input", globalConfig);
  const quantityButton = (0, _webElementHelper.getElementLocator)(page, direction === "increment" ? "quantity plus" : "quantity minus", globalConfig);
  const basketTotal = (0, _webElementHelper.getElementLocator)(page, "basket total", globalConfig);
  const qtyBefore = Number(await page.inputValue(quantityInput));
  const totalBefore = parsePrice(await page.textContent(basketTotal));
  const unitPrice = totalBefore / qtyBefore;
  const qtyAfter = direction === "increment" ? qtyBefore + 1 : qtyBefore - 1;
  await page.click(quantityButton);
  await (0, _waitForBehaviour.waitFor)(async () => (await page.inputValue(quantityInput)) === String(qtyAfter));
  await (0, _waitForBehaviour.waitFor)(async () => Math.abs(parsePrice(await page.textContent(basketTotal)) - unitPrice * qtyAfter) < 0.02);
});