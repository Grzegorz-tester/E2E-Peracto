"use strict";

var _cucumber = require("@cucumber/cucumber");
// For a URL that pagesConfig's fixed-route-per-pageId model can't express -
// a specific catalog item reached only via UI browsing elsewhere (e.g. a
// second, differently-templated PDP), or a path with a runtime-varying
// segment (e.g. a locale prefix). Everyday page navigation should still use
// "I am on the ... page" (PageId-based, resolves through pagesConfig) - this
// is the escape hatch for the cases that don't fit that model, not a
// replacement for it.
(0, _cucumber.Given)(/^I navigate directly to the path "([^"]*)"$/, async function (urlPath) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const {
    UI_AUTOMATION_HOST: hostName = "release_branch"
  } = process.env;
  const hostPath = globalConfig.hostsConfig[hostName];
  const url = new URL(hostPath);
  url.pathname = urlPath;
  await page.goto(url.href, {
    waitUntil: "domcontentloaded",
    timeout: 60000
  });
});