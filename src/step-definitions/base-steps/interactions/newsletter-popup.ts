import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";

// A MailerLite newsletter signup popup appears on a fresh page load and
// blocks every interaction underneath it until dismissed - not present
// when these tests were first written, discovered live while auditing
// this project. Its close button lives inside a third-party iframe with a
// dynamic src (a form id + cache-busting query params), so a plain CSS
// selector string can't reach it the way every other step in this
// framework does - frameLocator() is required, same class of exception as
// the CyberSource payment widget elsewhere in this codebase.
When(/^I dismiss the newsletter popup if present$/, async function (this: ScenarioWorld) {
    const { screen: { page } } = this;

    const closeButton = page.frameLocator('iframe[src*="mailerlite"]').getByRole("button", { name: "Close" });
    const appeared = await closeButton.waitFor({ state: "visible", timeout: 8000 }).then(() => true).catch(() => false);

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
});
