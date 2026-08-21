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
  await (0, _waitForBehaviour.waitFor)(() => (0, _navigationBehaviour.currentPathMatchesPageId)(page, pageId, globalConfig));
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
  await (0, _waitForBehaviour.waitFor)(() => page.url().includes(expectedText));
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
  });
});