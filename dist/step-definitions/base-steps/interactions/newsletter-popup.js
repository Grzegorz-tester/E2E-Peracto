"use strict";

var _cucumber = require("@cucumber/cucumber");
// A MailerLite newsletter signup popup appears on a fresh page load and
// blocks every interaction underneath it until dismissed - not present
// when these tests were first written, discovered live while auditing
// this project. Its close button lives inside a third-party iframe with a
// dynamic src (a form id + cache-busting query params), so a plain CSS
// selector string can't reach it the way every other step in this
// framework does - frameLocator() is required, same class of exception as
// the CyberSource payment widget elsewhere in this codebase.
(0, _cucumber.When)(/^I dismiss the newsletter popup if present$/, async function () {
  const {
    screen: {
      page
    }
  } = this;
  const closeButton = page.frameLocator('iframe[src*="mailerlite"]').getByRole("button", {
    name: "Close"
  });
  const appeared = await closeButton.waitFor({
    state: "visible",
    timeout: 8000
  }).then(() => true).catch(() => false);
  if (appeared) {
    await closeButton.click();
  }
});