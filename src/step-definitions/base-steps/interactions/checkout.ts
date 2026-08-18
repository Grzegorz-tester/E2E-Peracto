import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { ElementKey } from "../../../env/global";
import { CYBERSOURCE_TEST_CARDS, VERIFONE_TEST_CARDS } from "../../support-functions/payment-test-cards";

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

// For reusing the SAME throwaway email a later step in the scenario needs
// too (e.g. registering with it, then logging in as that same account) -
// pairs with "... with a unique guest email" above, which is what
// actually generates and stores it.
When(/^I fill in the "([^"]*)" input field with the stored guest email$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const guestEmail = this.globalVariables["guest email"];
    if (!guestEmail) {
        throw new Error(`No stored guest email found - "I fill in the ... with a unique guest email" must run first.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await page.fill(elementIdentifier, guestEmail);
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

// Barclays Verifone hosted card form (cst.checkout.vficloud.net), used by
// KOOL's "PAY ON CARD" checkout path. Confirmed live: the iframe's own
// field ids (#inputcc-number/#inputcc-exp/#inputnew-password) and submit
// button ([data-e2e="card-form-submit"]) are stable across sessions - this
// is the payment provider's own markup, not anything KOOL-specific, so
// reusable by any other project using the same Verifone integration.
//
// The CVV field renders with a `readonly` attribute (a common anti-autofill
// trick) that Playwright's .fill() refuses to act on ("element is not
// editable") - confirmed live that a real click().type() sequence works
// (the field presumably drops readonly on focus via its own JS), where
// .fill() does not. A short pause after the click is required too: typing
// immediately after the click dropped the CVV's first keystroke in a live
// run (got "23" instead of "123").
//
// Submitting always goes through real 3D Secure via Cardinal Commerce
// (device-fingerprinting request to geostag.cardinalcommerce.com, then
// lookupThreeDS/complete calls to vficloud.net). Use payment-test-cards.ts's
// visa/mastercard/amex entries for a card configured to pass
// "frictionlessly" (no challenge UI) - NOT the source suite's plain
// documented numbers (4111111111111111 etc.), which trigger an actual 3DS
// challenge that never resolves in headless Chromium at all (confirmed
// live: 40+s, no error, no resolution - looks like the fraud-detection
// layer never completing for automation).
//
// CONFIRMED WORKING once, live, end-to-end, with a full network trace:
// payment-transactions (201) -> lookupThreeDS -> complete ->
// /payment-return/checkout -> /checkout/thank-you, ~15-20s total. BUT
// several immediately-repeated attempts straight afterwards (same
// frictionless card, same everything) all then stalled at the exact same
// point instead of completing - never confirmed why, but the pattern
// (works once, then repeatedly doesn't, right after several dozen other
// automated checkout attempts against this same staging site in a short
// window) is consistent with a fraud-detection risk engine escalating to
// an actual challenge based on request velocity/device reputation, not
// just the test card's own designated behaviour. If this keeps failing,
// space live re-tests out rather than re-running back-to-back - don't
// assume the code is wrong just because a rapid-fire re-run doesn't
// reproduce the earlier success. Waits here for the resulting redirect
// through /payment-return/checkout to /checkout/thank-you rather than
// leaving that to the calling scenario's next step. The step itself also
// needs an explicit longer Cucumber step timeout (registered below) -
// confirmed live that the global SCRIPT_TIMEOUT default (20s) otherwise
// kills this step via Cucumber's own "function timed out" error before
// the internal waitForURL above ever gets the chance to.
When(/^I pay with the "([^"]*)" Verifone test card$/, { timeout: 60000 }, async function (this: ScenarioWorld, cardName: string) {
    const { screen: { page } } = this;

    const card = VERIFONE_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown Verifone test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    const cardFrame = page.frameLocator("iframe[src*='vficloud.net']");
    const cardNumberInput = cardFrame.locator("#inputcc-number");
    await cardNumberInput.waitFor({ state: "visible", timeout: 20000 });
    await cardNumberInput.fill(card.number);
    await cardFrame.locator("#inputcc-exp").fill(card.expiry);

    const cvvInput = cardFrame.locator("#inputnew-password");
    await cvvInput.click();
    await new Promise((resolve) => setTimeout(resolve, 400));
    await cvvInput.type(card.securityCode, { delay: 120 });

    await cardFrame.locator('[data-e2e="card-form-submit"]').click();
    await page.waitForURL(/\/(payment-return\/checkout|checkout\/thank-you)/, { timeout: 55000 });
});
