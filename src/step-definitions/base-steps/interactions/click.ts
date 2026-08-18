import { Given, When } from "@cucumber/cucumber";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import {
  clickElement,
  clickElementAtIndex,
} from "../../support-functions/html-behaviour";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// page.click() (via clickElement) already auto-waits for the element to
// become visible/actionable, so an extra page.waitForSelector before it is
// pure duplication, not extra safety - it just burns time twice. Each
// explicit timeout below is chosen to leave headroom under Cucumber's own
// step timeout (SCRIPT_TIMEOUT, 20000ms), so a slow page fails with a clear
// Playwright error instead of racing Cucumber's generic "function timed out".
//
// force: true skips only Playwright's "receives events"/"stable" checks -
// it still requires the element to be attached and visible first, so a
// genuinely-missing element still fails loudly. Added after the "Find a
// Retailer" map widget's live re-centering intermittently failed the
// "receives events" check on a result link that was, confirmed via direct
// inspection, perfectly clickable (elementFromPoint resolved to its own
// child text, not an overlapping element).
When(
  /^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/,
  async function (elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await new Promise((resolve) => setTimeout(resolve, 300));
    await clickElement(page, elementIdentifier, { timeout: 15000, force: true });
  }
);

When(
  /^I slowly click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/,
  async function (elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 10000 });
    await new Promise((resolve) => setTimeout(resolve, 6000));
    await clickElement(page, elementIdentifier, { timeout: 2000, force: true });
  }
);

// The inverse problem from force's own justification above: force clicks
// blindly at the target's bounding-box CENTER, which is wrong for a large
// element whose actual clickable content doesn't fill that box evenly -
// confirmed live on Watco's marketing-agreement <label>, which wraps a
// multi-line paragraph of explanatory text plus embedded links. A plain,
// non-forced click (Playwright's own actionability checks intact) toggled
// the checkbox correctly; the identical click with force: true landed on
// dead space within the label's box and silently did nothing - no error,
// just never checked. Reusable for any similarly oversized clickable
// wrapper (a label, a card, a banner) where force's own center-point
// assumption breaks down, without touching the force default every other
// call site here relies on.
When(
  /^I click precisely on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/,
  async function (elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await clickElement(page, elementIdentifier, { timeout: 15000 });
  }
);

// Combines "precisely" (above - no force, since force breaks this exact
// class of large-wrapper click) with a retry against an overlay that can
// intercept the click and REAPPEAR after being dismissed once - confirmed
// live on Watco (PL market): a single "dismiss the cookie preference
// centre if present, then click" still failed, because the overlay
// re-rendered in the gap between the dismiss and the click. Re-dismisses
// before every retry attempt, not just the first, mirroring the source
// Playwright suite's own retry-loop pattern for this exact site quirk
// (WatcoPDPage.addToBasket's stray-preference-centre handling).
When(
  /^I click precisely on the "([^"]*)" (?:button|link|icon|element|dropdown|tab), dismissing the "([^"]*)" if it interferes$/,
  { timeout: 45000 },
  async function (this: ScenarioWorld, elementKey: ElementKey, dismissButtonKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const dismissButtonIdentifier = getElementLocator(page, dismissButtonKey, globalConfig);

    let lastError: unknown;
    for (let attempt = 0; attempt < 5; attempt++) {
      const dismissButtonVisible = await page.locator(dismissButtonIdentifier).isVisible().catch(() => false);
      if (dismissButtonVisible) {
        await page.locator(dismissButtonIdentifier).click({ force: true }).catch(() => {});
        await page.locator(dismissButtonIdentifier).waitFor({ state: "hidden", timeout: 4000 }).catch(() => {});
      }
      try {
        await clickElement(page, elementIdentifier, { timeout: 8000 });
        return;
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError;
  }
);

// Force variant of the above, for an ordinary small button/link rather
// than an oversized wrapper - force is the right default here (see the
// plain "I click on the ... button" step's own reasoning at the top of
// this file), but still needs the dismiss-and-retry loop: an overlay
// sitting on top of the target still wins the browser's native hit-
// testing during event dispatch even with force: true - force only skips
// PLAYWRIGHT's own pre-click checks, not the browser deciding which
// element actually receives the click at that screen position. Confirmed
// live: Watco's "Register" submit button, several fields into the
// registration form, intermittently swallowed a forced click the exact
// same way the marketing-agreement label did - consistent with the
// preference-centre overlay reappearing mid-form, not a reCAPTCHA-timing
// issue as first suspected.
When(
  /^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab), dismissing the "([^"]*)" if it interferes$/,
  { timeout: 45000 },
  async function (this: ScenarioWorld, elementKey: ElementKey, dismissButtonKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const dismissButtonIdentifier = getElementLocator(page, dismissButtonKey, globalConfig);

    let lastError: unknown;
    for (let attempt = 0; attempt < 5; attempt++) {
      const dismissButtonVisible = await page.locator(dismissButtonIdentifier).isVisible().catch(() => false);
      if (dismissButtonVisible) {
        await page.locator(dismissButtonIdentifier).click({ force: true }).catch(() => {});
        await page.locator(dismissButtonIdentifier).waitFor({ state: "hidden", timeout: 4000 }).catch(() => {});
      }
      try {
        await clickElement(page, elementIdentifier, { timeout: 8000, force: true });
        return;
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError;
  }
);

// For an element that only sometimes appears (an optional interstitial, a
// modal shown only on a fresh page load, etc.) - clicks it if it shows up
// within a short window, otherwise moves on without failing the scenario.
When(
  /^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab) if present$/,
  async function (elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const appeared = await page
      .waitForSelector(elementIdentifier, { state: "visible", timeout: 8000 })
      .then(() => true)
      .catch(() => false);

    if (appeared) {
      // Confirms the click actually dismissed it, rather than firing once
      // and hoping - a click that doesn't register (or an element that
      // reappears, e.g. a cookie-consent banner re-triggered by a later
      // async request on the same page, confirmed live on one project)
      // would otherwise silently leave it blocking every subsequent
      // interaction in the scenario. Retries the click itself, not just
      // the wait, for exactly that reappearing case.
      await waitFor(async () => {
        await clickElement(page, elementIdentifier, { force: true });
        return page.waitForSelector(elementIdentifier, { state: "hidden", timeout: 4000 }).then(() => true).catch(() => false);
      }, { timeout: 20000, wait: 500 });
    }
  }
);

When(
  /^I click on the "(\d+(?:st|nd|rd|th))" "([^"]+)" (?:button|link|element)$/,
  async function (
    this: ScenarioWorld,
    elementPosition: string,
    elementKey: ElementKey
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    // Extract number from "2nd", "3rd", "10th", etc.
    const index = Number(elementPosition.match(/\d+/)?.[0]) - 1;

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await clickElementAtIndex(page, elementIdentifier, index, { force: true });
  }
);
