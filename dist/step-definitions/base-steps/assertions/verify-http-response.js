"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _test = require("@playwright/test");
// Checks the asset's own HTTP response rather than just "the <img> element
// is visible" - a broken/expired CDN URL can still render an <img> element
// with no visible layout break. Uses GET rather than HEAD since some CDNs
// (confirmed on other projects' image hosts) don't support HEAD and 404 it
// even when the resource itself is fine.
(0, _cucumber.Then)(/^the "([^"]*)" image should return a 200 OK response with content-type "([^"]*)"$/, async function (elementKey, expectedContentType) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const src = await page.getAttribute(elementIdentifier, "src");
  if (!src) {
    throw new Error(`"${elementKey}" (${elementIdentifier}) has no "src" attribute to check.`);
  }
  const url = new URL(src, page.url()).toString();
  const response = await page.request.get(url, {
    timeout: 15000
  });
  (0, _test.expect)(response.status(), `${url} -> ${response.status()}`).toBe(200);
  (0, _test.expect)(response.headers()["content-type"] ?? "").toContain(expectedContentType);
});

// Fetches a path remembered earlier in the scenario (e.g. a share link's
// href) directly, rather than navigating to it - navigating to a URL that
// serves an attachment makes Playwright's goto() throw "Download is
// starting". Uses the page's own request context, so it carries the
// current session (or the lack of one, after logging out), which is what
// "can someone without a login open this link" checks need.
(0, _cucumber.Then)(/^requesting the remembered path "([^"]*)" should return status (\d+)(?: with content-type "([^"]*)")?$/, async function (variableName, expectedStatus, expectedContentType) {
  const {
    screen: {
      page
    }
  } = this;
  const urlPath = this.globalVariables[variableName];
  if (urlPath === undefined) {
    throw new Error(`No remembered path found for "${variableName}".`);
  }
  const url = new URL(urlPath, page.url()).toString();
  const response = await page.request.get(url, {
    timeout: 15000,
    maxRedirects: 0
  });
  (0, _test.expect)(response.status(), `${url} -> ${response.status()}`).toBe(Number(expectedStatus));
  if (expectedContentType !== undefined) {
    (0, _test.expect)(response.headers()["content-type"] ?? "").toContain(expectedContentType);
  }
});