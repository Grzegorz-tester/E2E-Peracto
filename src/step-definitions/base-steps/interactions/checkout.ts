import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { ElementKey } from "../../../env/global";
import { CYBERSOURCE_TEST_CARDS } from "../../support-functions/payment-test-cards";

// Generates a disposable, throwaway guest email (not a real credential) and
// stashes it in globalVariables so a later step in the same scenario can
// assert the thank-you page shows the same address back. Reusable by any
// project's guest-checkout flow - just point elementKey at that project's
// own email input mapping.
When(/^I fill in the "([^"]*)" input field with a unique guest email$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const guestEmail = `guest.qa.${Date.now()}@velstar.co.uk`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await page.fill(elementIdentifier, guestEmail);

    this.globalVariables["guest email"] = guestEmail;
});

Then(/^the "([^"]*)" should contain the stored guest email$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const guestEmail = this.globalVariables["guest email"];
    if (!guestEmail) {
        throw new Error(`No stored guest email found - "I fill in the ... with a unique guest email" must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const elementText = await page.textContent(elementIdentifier);
        return elementText?.includes(guestEmail);
    });
});

// Multi-level address autocomplete (e.g. Loqate/Capture+ style): typing a
// search term shows street-level suggestions; picking one may expand to a
// further, more specific list - the number of levels isn't fixed, so this
// keeps clicking the current first option (re-queried fresh each attempt)
// until the real success signal (the submit button actually enabling) is
// observed, rather than assuming a fixed number of clicks. Reusable by any
// project using a similar autocomplete widget - point elementKey at that
// project's own search input; "address autocomplete listbox" / "address
// autocomplete options" / "Use this address" are resolved the same way,
// via that project's own mapping file.
When(/^I search for an address in the "([^"]*)" field using the term "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, searchTerm: string) {
    const { screen: { page }, globalConfig } = this;

    const searchInput = getElementLocator(page, elementKey, globalConfig);
    const listbox = getElementLocator(page, "address autocomplete listbox", globalConfig);
    const options = getElementLocator(page, "address autocomplete options", globalConfig);
    const submitButton = getElementLocator(page, "Use this address", globalConfig);

    await waitFor(async () => {
        await page.click(searchInput);
        await page.fill(searchInput, "");
        await new Promise((resolve) => setTimeout(resolve, 600));
        await page.type(searchInput, searchTerm, { delay: 30 });
        return page.waitForSelector(listbox, { state: "visible", timeout: 5000 }).then(() => true).catch(() => false);
    }, { timeout: 25000, wait: 500 });

    await waitFor(async () => {
        const optionsLocator = page.locator(options);
        if (await optionsLocator.count() > 0) {
            await optionsLocator.first().click();
        }
        return page.locator(submitButton).isEnabled();
    }, { timeout: 20000, wait: 500 });
});

// CyberSource Unified Checkout. Card fields live inside real iframes with
// no data-testid on the frames themselves, only stable ids. frameLocator()
// is required here since a plain CSS selector string cannot reach across
// an iframe boundary, unlike every other step in this framework - this is
// the one genuinely irreducible part of the checkout flow. Reusable by any
// project using the same CyberSource Unified Checkout widget, since the
// frame ids/testids below are the payment provider's own markup, not
// anything project-specific.
//
// Card details are looked up by name from payment-test-cards.ts rather
// than typed into the .feature file - different scenarios/products may
// need a different card (decline, 3DS, etc.), and adding one is a one-line
// addition to that file, no step-definition or feature-file changes.
When(/^I pay with the "([^"]*)" CyberSource test card$/, async function (this: ScenarioWorld, cardName: string) {
    const { screen: { page } } = this;

    const card = CYBERSOURCE_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown CyberSource test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    const buttonFrame = page.frameLocator("#__buttonlist");
    await buttonFrame.getByTestId("ctp-mini-btn").click();

    const cardFrame = page.frameLocator("#__mce");
    const cardNumberInput = cardFrame.locator("#card-number");
    await cardNumberInput.waitFor({ state: "visible", timeout: 20000 });
    await cardNumberInput.fill(card.number);
    await cardFrame.getByTestId("expiry-month").selectOption(card.expiryMonth);
    await cardFrame.getByTestId("expiry-year").selectOption(card.expiryYear);
    await cardFrame.locator("#card-security-code").fill(card.securityCode);
    await cardFrame.getByTestId("btn").click();

    const confirmButton = cardFrame.getByTestId("step-review-continue-btn");
    await confirmButton.waitFor({ state: "visible", timeout: 15000 });
    await confirmButton.click();
});
