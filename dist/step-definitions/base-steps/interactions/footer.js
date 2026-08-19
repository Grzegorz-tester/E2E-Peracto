"use strict";

var _cucumber = require("@cucumber/cucumber");
var _test = require("@playwright/test");
var _webElementHelper = require("../../support-functions/web-element-helper");
// Checks every link's own HTTP status via the page's request context
// (no full navigation per link) rather than clicking through each one -
// far faster, and a link that opens a modal/new tab or has a target
// other than the current page wouldn't be meaningfully "visited" by a
// click anyway. Dedupes by href first since the same link (e.g.
// "Sitemap") can legitimately appear more than once in the footer.
(0, _cucumber.Then)(/^all "([^"]*)" links should resolve without an error$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const containerSelector = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const hrefs = await page.locator(`${containerSelector} a:visible`).evaluateAll(els => els.map(el => el.getAttribute("href")).filter(href => !!href && !href.startsWith("mailto:") && !href.startsWith("tel:")));
  const uniqueHrefs = [...new Set(hrefs)];
  (0, _test.expect)(uniqueHrefs.length, `No links found in "${elementKey}" - check the selector/page state`).toBeGreaterThan(0);
  const failures = [];
  for (const href of uniqueHrefs) {
    const url = new URL(href, page.url()).toString();

    // Facebook rejects a plain, cookie-less GET with 400 regardless of
    // whether the page itself exists (confirmed live: a real, working
    // profile URL still 400s here) - not something this site controls,
    // so it's excluded rather than producing a permanent false failure.
    if (url.includes("facebook.com")) {
      continue;
    }
    try {
      const response = await page.request.get(url, {
        timeout: 15000
      });
      if (response.status() >= 400) {
        failures.push(`${href} -> ${response.status()}`);
      }
    } catch (error) {
      failures.push(`${href} -> ${error.message}`);
    }
  }
  (0, _test.expect)(failures, `Broken links found:\n${failures.join("\n")}`).toEqual([]);
});