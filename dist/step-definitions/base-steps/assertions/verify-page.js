"use strict";

var _cucumber = require("@cucumber/cucumber");
var _navigationBehaviour = require("../../support-functions/navigation-behaviour");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _webElementHelper = require("../../support-functions/web-element-helper");
(0, _cucumber.Then)(/^I should be redirected to the "([^"]*)" page$/, async function (pageId) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  await (0, _waitForBehaviour.waitFor)(() => (0, _navigationBehaviour.currentPathMatchesPageId)(page, pageId, globalConfig), {
    expected: `URL path to match the "${pageId}" page (route "${globalConfig.pagesConfig[pageId]?.route}", regex /${globalConfig.pagesConfig[pageId]?.regex}/)`,
    describeActual: async () => `current URL path is "${new URL(page.url()).pathname}"`
  });
});

// For a redirect that's genuinely just slow rather than broken - confirmed
// live on Indespension's search results page (the magnifier-glass search,
// not the Algolia autocomplete dropdown), which can take noticeably longer
// than the plain step's 15s waitFor default to actually navigate. Needs its
// own generous step timeout too, same convention as elsewhere in this repo -
// otherwise Cucumber's own SCRIPT_TIMEOUT (20s) kills the step first with an
// opaque "function timed out" before this waitFor's own 30s ever gets to
// finish or throw its clearer error. Reusable by any project with a
// similarly slow post-search/action redirect, not just this one.
(0, _cucumber.Then)(/^I should eventually be redirected to the "([^"]*)" page$/, {
  timeout: 35000
}, async function (pageId) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  await (0, _waitForBehaviour.waitFor)(() => (0, _navigationBehaviour.currentPathMatchesPageId)(page, pageId, globalConfig), {
    timeout: 30000,
    expected: `URL path to eventually match the "${pageId}" page (route "${globalConfig.pagesConfig[pageId]?.route}", regex /${globalConfig.pagesConfig[pageId]?.regex}/)`,
    describeActual: async () => `current URL path is "${new URL(page.url()).pathname}"`
  });
});

// For state that lives in the URL itself rather than a distinct page (e.g.
// an Algolia InstantSearch refinement like ?refinementList[...]=Soft+Close),
// where pagesConfig's page-identity matching doesn't apply.
(0, _cucumber.Then)(/^the current URL should contain "([^"]*)"$/, async function (expectedText) {
  const {
    screen: {
      page
    }
  } = this;
  await (0, _waitForBehaviour.waitFor)(() => page.url().includes(expectedText), {
    expected: `current URL to contain "${expectedText}"`,
    describeActual: async () => `current URL is "${page.url()}"`
  });
});

// For a "click the first item in the list" flow reused across a project
// whose sections don't all have data (e.g. Indespension's Redirects is
// genuinely empty right now, while KOOL's has real rows): if there was
// nothing to click, the URL never changes, so this accepts that as a valid
// outcome too - as long as the site's own confirmed-genuine empty message
// is what's actually showing, not a silently broken click.
(0, _cucumber.Then)(/^the current URL should contain "([^"]*)" or the "([^"]*)" should be displayed$/, async function (expectedText, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    const urlMatches = page.url().includes(expectedText);
    const elementVisible = (await page.$(elementIdentifier)) != null;
    return urlMatches || elementVisible;
  }, {
    expected: `current URL to contain "${expectedText}" or "${elementKey}" (${elementIdentifier}) to be displayed`,
    describeActual: async () => `current URL is "${page.url()}"; "${elementKey}": ${await (0, _webElementHelper.describeElement)(page, elementIdentifier)}`
  });
});