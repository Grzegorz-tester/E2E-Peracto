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
