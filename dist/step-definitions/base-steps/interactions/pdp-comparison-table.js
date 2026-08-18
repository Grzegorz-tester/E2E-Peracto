"use strict";

var _cucumber = require("@cucumber/cucumber");
var _test = require("@playwright/test");
var _webElementHelper = require("../../support-functions/web-element-helper");
// Picks a different product from the comparison table (excluding the one
// currently being viewed) and navigates to it via its "View Product" link,
// remembering the target's own name (read from its column's image alt text)
// so a later assertion can confirm the correct PDP was reached - see "the
// ... text should equal the remembered ..." in verify-element-value.ts.
(0, _cucumber.When)(/^I click "View Product" for a different product in the comparison table, remembering its name as "([^"]*)"$/, async function (variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const linksSelector = (0, _webElementHelper.getElementLocator)(page, "comparison table view product links", globalConfig);
  const links = page.locator(linksSelector);
  await (0, _test.expect)(links.first()).toBeVisible({
    timeout: 30000
  });
  const currentHref = new URL(page.url()).pathname;
  const candidates = await links.evaluateAll((els, current) => els.map(el => ({
    href: el.getAttribute("href") ?? "",
    name: el.closest("th")?.querySelector("img")?.getAttribute("alt") ?? ""
  })).filter(p => p.href !== current), currentHref);
  const target = candidates[0];
  if (!target) {
    throw new Error("No other product found in the comparison table.");
  }
  const link = page.locator(`a[href="${target.href}"]`).first();
  await (0, _test.expect)(link).toBeVisible({
    timeout: 15000
  });
  await link.click();
  await (0, _test.expect)(page).toHaveURL(new RegExp(`${target.href}$`), {
    timeout: 30000
  });
  this.globalVariables[variableName] = target.name;
});