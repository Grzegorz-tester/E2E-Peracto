"use strict";

var _cucumber = require("@cucumber/cucumber");
var _test = require("@playwright/test");
var _webElementHelper = require("../../support-functions/web-element-helper");
// Shared by both steps below: checks each href's own HTTP status via the
// page's request context (no full navigation per link) rather than
// clicking through each one - far faster, and a link that opens a modal/
// new tab or has a target other than the current page wouldn't be
// meaningfully "visited" by a click anyway.
const checkLinksResolve = async (page, hrefs) => {
  const failures = [];
  for (const href of hrefs) {
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
};

// Shared by both steps below: the mapping value must resolve DIRECTLY to
// the <a> elements to check (not a container needing further descendant
// narrowing). Deliberately NOT filtered by visibility - tried three ways
// (a DOM offsetParent check, then Playwright's own "visible=true" pseudo-
// engine) and both wrongly excluded a whole legitimate result set: a
// sitemap page's category/article links are all `display: none` on this
// site (no visible toggle to reveal them - looks like a genuine rendering
// bug, not a deliberately-collapsed section), yet a sitemap's entire
// purpose is enumerating crawlable URLs for search engines, which still
// index links present in the DOM regardless of CSS visibility - so
// visibility was never the right filter for that use case, and turns out
// to be unnecessary for the footer use case too: a hidden mobile/desktop
// duplicate shares the same href as its visible counterpart, so the
// Set-based href dedup below already collapses it without needing a
// visibility check at all. Also sidesteps a real bug found along the way:
// concatenating a suffix onto an XPath-starting selector breaks outright
// (Playwright auto-detects "xpath" from a leading "//", and the combined
// string stops being valid XPath) - confirmed live on this same sitemap
// page's href-pattern-matched links, which need XPath's "contains()".
const gatherHrefs = async (page, elementIdentifier) => {
  const hrefs = await page.locator(elementIdentifier).evaluateAll(els => els.map(el => el.getAttribute("href")).filter(href => !!href && !href.startsWith("mailto:") && !href.startsWith("tel:")));
  return [...new Set(hrefs)];
};
(0, _cucumber.Then)(/^all "([^"]*)" links should resolve without an error$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const uniqueHrefs = await gatherHrefs(page, elementIdentifier);
  (0, _test.expect)(uniqueHrefs.length, `No links found in "${elementKey}" - check the selector/page state`).toBeGreaterThan(0);
  await checkLinksResolve(page, uniqueHrefs);
});

// For a listing too large to check exhaustively (e.g. a sitemap page
// enumerating every product - checking all ~2000 would be slow and an
// unnecessarily heavy crawl of the site) - checks a bounded sample instead,
// same as the smoke test itself asks for ("open sample product/page/
// article URLs"), not every one of them.
(0, _cucumber.Then)(/^the first (\d+) "([^"]*)" links should resolve without an error$/, async function (count, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const uniqueHrefs = (await gatherHrefs(page, elementIdentifier)).slice(0, Number(count));
  (0, _test.expect)(uniqueHrefs.length, `No links found in "${elementKey}" - check the selector/page state`).toBeGreaterThan(0);
  await checkLinksResolve(page, uniqueHrefs);
});