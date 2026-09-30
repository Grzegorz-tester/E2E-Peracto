import { Given, Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { describeLocator, getElementLocator } from "../../support-functions/web-element-helper";
import { clickElement, enterValue, withActionDiagnostics } from "../../support-functions/html-behaviour";
import { ElementKey } from "../../../env/global";
import { CYBERSOURCE_TEST_CARDS, VERIFONE_TEST_CARDS, GLOBALPAYMENTS_TEST_CARDS, BRAINTREE_TEST_CARDS } from "../../support-functions/payment-test-cards";

// Second, independent layer of protection beyond the @places-real-order tag
// exclusion wired into src/index.ts's productionExclusion (see CLAUDE.md's
// "Staging vs production rules": never place a real order on a live
// storefront). Called directly from every step below that actually submits
// a payment and completes a real order, so it can't be bypassed by a
// missing/misconfigured tag - it re-derives the same UI_AUTOMATION_HOST
// check independently, the same source navigation-behaviour.ts's own
// navigateToPage reads. Mirrors admin-address-book.ts's "I require a
// staging admin for this scenario", the same pattern applied to
// order-placing instead of admin mutation.
function refuseIfProduction(action: string) {
    if (process.env.UI_AUTOMATION_HOST === "production") {
        throw new Error(
            `Refusing to run: "${action}" places a real order and UI_AUTOMATION_HOST is "production". ` +
            `This should already be excluded via the @places-real-order tag in src/index.ts - seeing this error means that exclusion didn't apply, or this step was reached outside a tag-filtered cucumber run.`
        );
    }
}

// Reusable scenario-level version of the same guard, for order-completing
// actions that go through the generic "I click on the ... button" step
// rather than a bespoke payment step (e.g. KOOL's "PAY ON ACCOUNT", Watco's
// "Pay on Account"/Adyen "Pay by card" flows) - those can't be guarded
// individually without hardcoding project-specific button text into the
// generic click step. Add this as the first step of any scenario tagged
// @places-real-order so it refuses to run the instant the scenario starts,
// the same double-layer guarantee as the bespoke card-payment steps below.
Given(/^I require staging for this scenario$/, async function () {
    refuseIfProduction("this scenario (places a real order)");
});

// Production-safe alternative to tagging a whole scenario @places-real-order
// / @submits-real-form / @completes-registration: use this for the ONE click
// that commits something real (Place order, Confirm Your Booking, a real
// form submit), so everything up to it still runs on production. Off
// production it is the plain "I click on the ... button" step. On
// production it only asserts the target is visible and enabled - i.e. the
// journey genuinely reached a submittable state - then returns "skipped",
// which stops the scenario there (every later step is skipped, nothing is
// clicked) and shows it as skipped rather than passed in the report, so a
// production run never claims the confirmation page was verified.
When(
    /^I click on the "([^"]*)" (?:button|link|element) as the final real submission$/,
    async function (this: ScenarioWorld, elementKey: ElementKey) {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

        if (process.env.UI_AUTOMATION_HOST === "production") {
            const target = page.locator(elementIdentifier).first();
            await expect(target, `Expected "${elementKey}" to be visible before the final real submission`).toBeVisible({ timeout: 15000 });
            await expect(target, `Expected "${elementKey}" to be enabled before the final real submission`).toBeEnabled({ timeout: 10000 });
            this.attach(`Production run: stopped before clicking "${elementKey}" (the final real submission). It was visible and enabled; this and every later step are intentionally skipped.`);
            return "skipped";
        }

        await new Promise((resolve) => setTimeout(resolve, 300));
        await clickElement(page, elementIdentifier, { timeout: 15000, force: true });
    }
);

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
    await enterValue(page, elementIdentifier, guestEmail);

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
    await enterValue(page, elementIdentifier, guestEmail);
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
    }, {
        expected: `"${elementKey}" (${elementIdentifier}) to contain the stored guest email "${guestEmail}"`,
        describeActual: async () => `text was "${(await page.textContent(elementIdentifier).catch(() => null))?.trim() ?? "(could not read text)"}"`,
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
//
// The two waitFor calls below total up to 45s (25s + 20s) worst case, which
// exceeds some projects' SCRIPT_TIMEOUT (as low as 20000ms) - confirmed live
// on Insinkerator EU: Cucumber's own generic step timeout fired
// ("function timed out ... 20000 milliseconds") before either waitFor's own
// more descriptive error could. An explicit per-step timeout, generous
// rather than tightly calculated (see the same fix applied to the "if
// present" click step), removes the dependency on whatever SCRIPT_TIMEOUT
// happens to be configured for a given project.
When(
  /^I search for an address in the "([^"]*)" field using the term "([^"]*)"$/,
  { timeout: 60000 },
  async function (this: ScenarioWorld, elementKey: ElementKey, searchTerm: string) {
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
    }, {
        timeout: 25000,
        wait: 500,
        expected: `"address autocomplete listbox" (${listbox}) to appear after typing "${searchTerm}" into "${elementKey}" (${searchInput})`,
        describeActual: () => describeLocator(page.locator(listbox), `"address autocomplete listbox" (${listbox})`),
    });

    await waitFor(async () => {
        const optionsLocator = page.locator(options);
        if (await optionsLocator.count() > 0) {
            await optionsLocator.first().click();
        }
        return page.locator(submitButton).isEnabled();
    }, {
        timeout: 20000,
        wait: 500,
        expected: `"Use this address" (${submitButton}) to become enabled after picking an "address autocomplete options" (${options}) suggestion`,
        describeActual: () => describeLocator(page.locator(submitButton), `"Use this address" (${submitButton})`),
    });
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
    refuseIfProduction(`I pay with the "${cardName}" CyberSource test card`);
    const { screen: { page } } = this;

    const card = CYBERSOURCE_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown CyberSource test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    const buttonFrame = page.frameLocator("#__buttonlist");
    const miniButton = buttonFrame.getByTestId("ctp-mini-btn");
    await withActionDiagnostics(
        `to click the CyberSource "ctp-mini-btn"`,
        () => describeLocator(miniButton, `CyberSource "ctp-mini-btn"`),
        () => miniButton.click()
    );

    const cardFrame = page.frameLocator("#__mce");
    const cardNumberInput = cardFrame.locator("#card-number");
    await cardNumberInput.waitFor({ state: "visible", timeout: 20000 });
    await withActionDiagnostics(
        `to fill CyberSource "#card-number"`,
        () => describeLocator(cardNumberInput, `CyberSource "#card-number"`),
        () => cardNumberInput.fill(card.number)
    );
    const expiryMonth = cardFrame.getByTestId("expiry-month");
    await withActionDiagnostics(
        `to select expiry month "${card.expiryMonth}" on CyberSource "expiry-month"`,
        () => describeLocator(expiryMonth, `CyberSource "expiry-month"`),
        () => expiryMonth.selectOption(card.expiryMonth)
    );
    const expiryYear = cardFrame.getByTestId("expiry-year");
    await withActionDiagnostics(
        `to select expiry year "${card.expiryYear}" on CyberSource "expiry-year"`,
        () => describeLocator(expiryYear, `CyberSource "expiry-year"`),
        () => expiryYear.selectOption(card.expiryYear)
    );
    const securityCodeInput = cardFrame.locator("#card-security-code");
    await withActionDiagnostics(
        `to fill CyberSource "#card-security-code"`,
        () => describeLocator(securityCodeInput, `CyberSource "#card-security-code"`),
        () => securityCodeInput.fill(card.securityCode)
    );
    const payButton = cardFrame.getByTestId("btn");
    await withActionDiagnostics(
        `to click CyberSource "btn"`,
        () => describeLocator(payButton, `CyberSource "btn"`),
        () => payButton.click()
    );

    const confirmButton = cardFrame.getByTestId("step-review-continue-btn");
    await confirmButton.waitFor({ state: "visible", timeout: 15000 });
    await withActionDiagnostics(
        `to click CyberSource "step-review-continue-btn"`,
        () => describeLocator(confirmButton, `CyberSource "step-review-continue-btn"`),
        () => confirmButton.click()
    );
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
    refuseIfProduction(`I pay with the "${cardName}" Verifone test card`);
    const { screen: { page } } = this;

    const card = VERIFONE_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown Verifone test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    const cardFrame = page.frameLocator("iframe[src*='vficloud.net']");
    const cardNumberInput = cardFrame.locator("#inputcc-number");
    await cardNumberInput.waitFor({ state: "visible", timeout: 20000 });
    await withActionDiagnostics(
        `to fill Verifone "#inputcc-number"`,
        () => describeLocator(cardNumberInput, `Verifone "#inputcc-number"`),
        () => cardNumberInput.fill(card.number)
    );
    const expiryInput = cardFrame.locator("#inputcc-exp");
    await withActionDiagnostics(
        `to fill Verifone "#inputcc-exp"`,
        () => describeLocator(expiryInput, `Verifone "#inputcc-exp"`),
        () => expiryInput.fill(card.expiry)
    );

    const cvvInput = cardFrame.locator("#inputnew-password");
    await withActionDiagnostics(
        `to click Verifone "#inputnew-password"`,
        () => describeLocator(cvvInput, `Verifone "#inputnew-password"`),
        () => cvvInput.click()
    );
    await new Promise((resolve) => setTimeout(resolve, 400));
    await withActionDiagnostics(
        `to type the security code into Verifone "#inputnew-password"`,
        () => describeLocator(cvvInput, `Verifone "#inputnew-password"`),
        () => cvvInput.type(card.securityCode, { delay: 120 })
    );

    const submitButton = cardFrame.locator('[data-e2e="card-form-submit"]');
    await withActionDiagnostics(
        `to click Verifone "[data-e2e='card-form-submit']"`,
        () => describeLocator(submitButton, `Verifone "[data-e2e='card-form-submit']"`),
        () => submitButton.click()
    );
    await page.waitForURL(/\/(payment-return\/checkout|checkout\/thank-you)/, { timeout: 55000 });
});

// For a card expected to FAIL (declined/expired) rather than succeed - the
// "successful" step above waits for the redirect to thank-you, which never
// happens here, so it can't be reused as-is. No 3D Secure is involved for
// these (confirmed in payment-test-cards.ts), so this is expected to
// resolve quickly and isn't subject to the same fraud-detection/Cardinal
// Commerce concerns as a real payment attempt. Confirmed live: a declined
// card doesn't render an explicit visible error message anywhere in the DOM
// - the observable signal is that Worldpay/Verifone drops the user back to
// its own payment-method-selection screen instead of redirecting away, so
// that's what's waited for here rather than a message that doesn't exist.
When(/^I attempt to pay with the "([^"]*)" Verifone test card$/, { timeout: 30000 }, async function (this: ScenarioWorld, cardName: string) {
    const { screen: { page } } = this;

    const card = VERIFONE_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown Verifone test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    const cardFrame = page.frameLocator("iframe[src*='vficloud.net']");
    const cardNumberInput = cardFrame.locator("#inputcc-number");
    await cardNumberInput.waitFor({ state: "visible", timeout: 20000 });
    await withActionDiagnostics(
        `to fill Verifone "#inputcc-number"`,
        () => describeLocator(cardNumberInput, `Verifone "#inputcc-number"`),
        () => cardNumberInput.fill(card.number)
    );
    const expiryInput = cardFrame.locator("#inputcc-exp");
    await withActionDiagnostics(
        `to fill Verifone "#inputcc-exp"`,
        () => describeLocator(expiryInput, `Verifone "#inputcc-exp"`),
        () => expiryInput.fill(card.expiry)
    );

    const cvvInput = cardFrame.locator("#inputnew-password");
    await withActionDiagnostics(
        `to click Verifone "#inputnew-password"`,
        () => describeLocator(cvvInput, `Verifone "#inputnew-password"`),
        () => cvvInput.click()
    );
    await new Promise((resolve) => setTimeout(resolve, 400));
    await withActionDiagnostics(
        `to type the security code into Verifone "#inputnew-password"`,
        () => describeLocator(cvvInput, `Verifone "#inputnew-password"`),
        () => cvvInput.type(card.securityCode, { delay: 120 })
    );

    const submitButton = cardFrame.locator('[data-e2e="card-form-submit"]');
    await withActionDiagnostics(
        `to click Verifone "[data-e2e='card-form-submit']"`,
        () => describeLocator(submitButton, `Verifone "[data-e2e='card-form-submit']"`),
        () => submitButton.click()
    );
    await cardFrame.locator(':text("Select a payment method")').first().waitFor({ state: "visible", timeout: 20000 });
});

// Adyen drop-in (Watco's card payment provider). Needed on markets where
// Pay on Account isn't offered at all (PL) - the only way to get an
// order-completing test there. The three card fields live in Adyen's own
// hosted iframes (data-cse="encrypted...") with no project-specific
// markup, same "irreducible, needs frameLocator" situation as the
// CyberSource/Verifone steps above. Selectors and the test card itself
// (4111111111111111 / 03/30 / 737) are VERIFIED live (staging,
// 2026-08-06) - staging's Adyen client config runs in test mode, so this
// resolves with no 3D Secure challenge. Assumes "Pay by card" has
// already been selected and its terms checkbox checked (the same
// two-step pattern "Pay on Account" already uses elsewhere) - this step
// only handles the drop-in fields themselves, not clicking the final pay
// button, so it composes with the existing "I click on the ... button"
// step for that.
When(/^I fill in the Adyen test card details$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;

    const dropinReady = getElementLocator(page, "Adyen dropin ready", globalConfig);
    await page.waitForSelector(dropinReady, { state: "visible", timeout: 15000 });

    const cardholderName = getElementLocator(page, "Adyen cardholder name", globalConfig);
    await enterValue(page, cardholderName, "Test Test");

    const cardNumberInput = page.frameLocator('[data-cse="encryptedCardNumber"] iframe')
        .locator('input[data-fieldtype="encryptedCardNumber"]');
    await withActionDiagnostics(
        `to fill Adyen "encryptedCardNumber"`,
        () => describeLocator(cardNumberInput, `Adyen "encryptedCardNumber"`),
        () => cardNumberInput.fill("4111111111111111")
    );
    const expiryDateInput = page.frameLocator('[data-cse="encryptedExpiryDate"] iframe')
        .locator('input[data-fieldtype="encryptedExpiryDate"]');
    await withActionDiagnostics(
        `to fill Adyen "encryptedExpiryDate"`,
        () => describeLocator(expiryDateInput, `Adyen "encryptedExpiryDate"`),
        () => expiryDateInput.fill("03/30")
    );
    const securityCodeInput = page.frameLocator('[data-cse="encryptedSecurityCode"] iframe')
        .locator('input[data-fieldtype="encryptedSecurityCode"]');
    await withActionDiagnostics(
        `to fill Adyen "encryptedSecurityCode"`,
        () => describeLocator(securityCodeInput, `Adyen "encryptedSecurityCode"`),
        () => securityCodeInput.fill("737")
    );
});

// PayPal SDK button rendered inside its own iframe (no testid, no stable
// frame name - third-party markup) that opens a real POPUP window rather
// than redirecting in-tab. CONFIRMED live on Russells (staging, 2026-08-03):
// this integration points at PayPal's PRODUCTION environment even on
// staging (the popup's own URL carries env=production), so clicking
// through and authenticating would place a genuine PayPal transaction -
// this step deliberately stops at confirming the popup opens and lands on
// paypal.com, and never logs in or completes a payment. CONFIRMED live
// (2026-08-07): the SDK button intermittently doesn't open its popup on
// the first click (a genuine third-party init-timing issue, same class of
// flakiness already documented for Global Payments below) - retried as a
// whole, with a fresh waitForEvent each attempt, since a stale event
// promise can't be reused. elementKey should resolve to the PayPal link/
// button itself (inside its iframe, via the calling project's own mapping
// - a plain CSS selector string can't reach across an iframe boundary, so
// this reads the RAW selector value and re-wraps it in frameLocator here,
// the one case in this file needing an iframe boundary).
When(/^I click on the "([^"]*)" button and verify it opens a popup redirecting to "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, expectedHost: string) {
    const { screen: { page }, globalConfig } = this;
    const frameSelector = getElementLocator(page, `${elementKey} iframe`, globalConfig);
    const buttonSelector = getElementLocator(page, elementKey, globalConfig);

    await expect(async () => {
        const popupPromise = page.context().waitForEvent("page", { timeout: 15000 });
        await page.frameLocator(frameSelector).locator(buttonSelector).click();
        const popup = await popupPromise;
        await popup.waitForLoadState("domcontentloaded");
        await expect(popup).toHaveURL(new RegExp(expectedHost.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), { timeout: 20000 });
        await popup.close();
    }).toPass({ timeout: 60000 });
});

// GlobalPayments (js.globalpay.com) hosted fields - Indespension's card
// payment provider. Each field (number/expiration/cvv/holder-name/submit)
// is its own named iframe with no data-testid, only id="secure-payment-
// field" on the real input - confirmed live that each iframe ALSO
// contains hidden aria-hidden autocomplete-helper inputs for the OTHER
// three fields (for browser autofill UX), so a bare `input` locator
// matches 4 elements per frame; `#secure-payment-field` reliably isolates
// the one real, interactive field. Card details looked up by name from
// payment-test-cards.ts, same convention as the CyberSource/Verifone
// steps above.
//
// IMPORTANT (confirmed live, 2026-08-21): submitting currently always
// fails with "Payment Error: no gateway available" regardless of card -
// this is a staging environment/gateway-configuration gap, not a card or
// selector problem (see the comment on GLOBALPAYMENTS_TEST_CARDS). This
// step itself is verified correct up to and including the submit click;
// only the resulting redirect is blocked. Waits for either a real
// checkout-thank-you redirect or that specific payment-error text (a
// scenario using this step needs to handle both outcomes explicitly
// rather than assuming success).
When(/^I pay with the "([^"]*)" GlobalPayments test card$/, { timeout: 30000 }, async function (this: ScenarioWorld, cardName: string) {
    refuseIfProduction(`I pay with the "${cardName}" GlobalPayments test card`);
    const { screen: { page } } = this;

    const card = GLOBALPAYMENTS_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown GlobalPayments test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    await page.waitForSelector('iframe[name="card-number"]', { state: "visible", timeout: 15000 });

    const numberInput = page.frameLocator('iframe[name="card-number"]').locator('#secure-payment-field');
    await withActionDiagnostics(
        `to fill GlobalPayments "card-number"`,
        () => describeLocator(numberInput, `GlobalPayments "card-number"`),
        () => numberInput.fill(card.number)
    );
    const expirationInput = page.frameLocator('iframe[name="card-expiration"]').locator('#secure-payment-field');
    await withActionDiagnostics(
        `to fill GlobalPayments "card-expiration"`,
        () => describeLocator(expirationInput, `GlobalPayments "card-expiration"`),
        () => expirationInput.fill(card.expiry)
    );
    const cvvInput = page.frameLocator('iframe[name="card-cvv"]').locator('#secure-payment-field');
    await withActionDiagnostics(
        `to fill GlobalPayments "card-cvv"`,
        () => describeLocator(cvvInput, `GlobalPayments "card-cvv"`),
        () => cvvInput.fill(card.securityCode)
    );
    const holderNameInput = page.frameLocator('iframe[name="card-holder-name"]').locator('#secure-payment-field');
    await withActionDiagnostics(
        `to fill GlobalPayments "card-holder-name"`,
        () => describeLocator(holderNameInput, `GlobalPayments "card-holder-name"`),
        () => holderNameInput.fill("Velstar Test")
    );

    const submitButton = page.frameLocator('iframe[name="submit"]').locator('#secure-payment-field, button, input[type="submit"]').first();
    await withActionDiagnostics(
        `to click GlobalPayments "submit"`,
        () => describeLocator(submitButton, `GlobalPayments "submit"`),
        () => submitButton.click()
    );
});

// Braintree Drop-in (Card / PayPal / Google Pay sheet), e.g. Keylite's
// Review & Pay step - assumes the Drop-in is already rendered (Keylite: after
// clicking "Pay now"). Selects the Card option, fills the two hosted iframe
// fields (number, expiry - no CVV in this integration), then clicks the
// Drop-in's own "Confirm Payment". Does NOT wait for the result - follow it
// with an "I should eventually be redirected to ..." assertion, since
// tokenising + 3-D Secure + the merchant's own transaction call take ~5-10s.
// See BRAINTREE_TEST_CARDS for why the frictionless 3DS card is the one to
// use (the plain 4111... Visa stalls on a 3DS challenge).
When(/^I pay with the "([^"]*)" Braintree test card$/, { timeout: 60000 }, async function (this: ScenarioWorld, cardName: string) {
    refuseIfProduction(`I pay with the "${cardName}" Braintree test card`);
    const { screen: { page } } = this;

    const card = BRAINTREE_TEST_CARDS[cardName];
    if (!card) {
        throw new Error(`Unknown Braintree test card "${cardName}". Add it to payment-test-cards.ts.`);
    }

    const cardOption = page.locator(".braintree-option__card").first();
    await cardOption.waitFor({ state: "visible", timeout: 20000 });
    await withActionDiagnostics(
        `to select the Braintree "Card" option`,
        () => describeLocator(cardOption, `Braintree ".braintree-option__card"`),
        () => cardOption.evaluate((element) => (element as HTMLElement).click())
    );

    await page.waitForSelector('iframe[name="braintree-hosted-field-number"]', { state: "visible", timeout: 15000 });
    const numberInput = page.frameLocator('iframe[name="braintree-hosted-field-number"]').locator("input#credit-card-number");
    await withActionDiagnostics(
        `to fill Braintree "credit-card-number"`,
        () => describeLocator(numberInput, `Braintree "credit-card-number"`),
        () => numberInput.fill(card.number)
    );
    const expirationInput = page.frameLocator('iframe[name="braintree-hosted-field-expirationDate"]').locator("input#expiration");
    await withActionDiagnostics(
        `to fill Braintree "expiration"`,
        () => describeLocator(expirationInput, `Braintree "expiration"`),
        () => expirationInput.fill(card.expiry)
    );

    const confirmButton = page.locator("button:visible", { hasText: "Confirm Payment" }).last();
    await withActionDiagnostics(
        `to click Braintree "Confirm Payment"`,
        () => describeLocator(confirmButton, `Braintree "Confirm Payment"`),
        () => confirmButton.click()
    );
});
