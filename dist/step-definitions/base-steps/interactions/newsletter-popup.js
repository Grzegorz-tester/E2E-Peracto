"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.dismissNewsletterPopup = void 0;
var _cucumber = require("@cucumber/cucumber");
// A MailerLite newsletter signup popup appears on a fresh page load and
// blocks every interaction underneath it until dismissed - not present
// when these tests were first written, discovered live while auditing
// this project. Its close button lives inside a third-party iframe with a
// dynamic src (a form id + cache-busting query params), so a plain CSS
// selector string can't reach it the way every other step in this
// framework does - frameLocator() is required, same class of exception as
// the CyberSource payment widget elsewhere in this codebase.
//
// Exported (not just a Cucumber step) so the compound "I am navigating the
// page as a ... user" step (user.ts) can call the SAME dismissal logic
// after its own login-page navigation, rather than duplicating a
// MailerLite-only copy that silently misses other projects' popup vendors -
// confirmed live on Keylite: that duplicated copy left its Mailchimp popup
// undismissed, intermittently blocking the Sign In click and timing out the
// whole login step.
const dismissNewsletterPopup = async page => {
  const closeButton = page.frameLocator('iframe[src*="mailerlite"]').getByRole("button", {
    name: "Close"
  });
  const appeared = await closeButton.waitFor({
    state: "visible",
    timeout: 8000
  }).then(() => true).catch(() => false);
  if (appeared) {
    await closeButton.click();
    return;
  }

  // Keylite's newsletter popup is a Mailchimp embedded form (container id
  // "mcforms-<formId>-<uid>") rather than MailerLite's iframe. Confirmed
  // live: it loads asynchronously and its own aria-label="Close" button
  // never reports as Playwright-"visible" in headless mode even though the
  // popup still visually blocks clicks on whatever's underneath it - so it
  // is removed from the DOM directly rather than clicked.
  await page.evaluate(() => {
    document.querySelector('[id^="mcforms-"]')?.remove();
  });
};
exports.dismissNewsletterPopup = dismissNewsletterPopup;
(0, _cucumber.When)(/^I dismiss the newsletter popup if present$/, async function () {
  const {
    screen: {
      page
    }
  } = this;
  await dismissNewsletterPopup(page);
});