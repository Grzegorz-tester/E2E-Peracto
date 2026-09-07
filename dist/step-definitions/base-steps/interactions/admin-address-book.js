"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
// Second, independent layer of protection beyond the @mutates-admin-data
// tag exclusion wired into src/index.ts's productionExclusion - if a
// scenario's tag were ever missing, or a profile's tag filter got
// misconfigured, this makes the scenario refuse to run the instant it
// starts, rather than silently adding/editing/deleting real address data
// on a tenant's production admin (see CLAUDE.md's "Staging vs production
// rules": a production admin must stay read-only). Deliberately does not
// depend on the tag exclusion in any way - it re-derives the same
// UI_AUTOMATION_HOST check independently, the same source
// navigation-behaviour.ts's own navigateToPage reads.
(0, _cucumber.Given)(/^I require a staging admin for this scenario$/, async function () {
  if (process.env.UI_AUTOMATION_HOST === "production") {
    throw new Error("Refusing to run: this scenario mutates admin data (adds/edits/deletes a user's address) and UI_AUTOMATION_HOST is \"production\". " + "This should already be excluded via the @mutates-admin-data tag in src/index.ts - seeing this error means that exclusion didn't apply.");
  }
});

// Peracto Admin renders each saved address as a plain read-only block
// (an "address entry", e.g. "<address>...</address>") with its own Edit
// button as a following SIBLING, not a child - confirmed live (Carbon
// Admin staging, 2026-08-31). A user can have several unrelated real
// addresses already, so this finds the one containing whatever this
// scenario itself created (identified by its own remembered marker
// value) rather than assuming "the first" or "the last" address is ours.
(0, _cucumber.When)(/^I click the "Edit" button for the address containing the remembered "([^"]*)"$/, async function (variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const remembered = this.globalVariables[variableName];
  if (remembered === undefined) {
    throw new Error(`No remembered text found for "${variableName}" - a "... remembering it as ..." step must run first.`);
  }
  const addressIdentifier = (0, _webElementHelper.getElementLocator)(page, "address entry", globalConfig);
  const addressEntry = page.locator(addressIdentifier).filter({
    hasText: remembered
  });
  await addressEntry.first().waitFor({
    state: "visible",
    timeout: 15000
  });
  await addressEntry.first().locator("xpath=following-sibling::button[1]").click();
});