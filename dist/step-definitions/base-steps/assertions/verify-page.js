"use strict";

var _cucumber = require("@cucumber/cucumber");
var _navigationBehaviour = require("../../support-functions/navigation-behaviour");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
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