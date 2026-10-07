import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { describeElement, getElementLocator } from "../../support-functions/web-element-helper";
import { expect } from "@playwright/test";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { ElementKey } from "../../../env/global";

// For a list page where "no rows" can mean two very different things: a
// genuine empty result set (the site's own "no results" message renders) or
// the data silently failing to load (a heading/shell renders, but nothing
// underneath it - e.g. a 500 fetching the list). Checking only that a
// heading is present can't tell these apart; this requires ACTUAL content
// (either real rows or the confirmed-genuine empty-state message), so a
// broken/empty-by-accident page still fails.
Then(
  /^the "([^"]*)" should be displayed or the "([^"]*)" should be displayed$/,
  async function (this: ScenarioWorld, firstElementKey: string, secondElementKey: string) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const firstIdentifier = getElementLocator(page, firstElementKey, globalConfig);
    const secondIdentifier = getElementLocator(page, secondElementKey, globalConfig);

    await waitFor(async () => {
      const firstVisible = (await page.$(firstIdentifier)) != null;
      const secondVisible = (await page.$(secondIdentifier)) != null;
      return firstVisible || secondVisible;
    }, {
      expected: `"${firstElementKey}" or "${secondElementKey}" to be displayed`,
      describeActual: async () =>
        `"${firstElementKey}": ${await describeElement(page, firstIdentifier)}; "${secondElementKey}": ${await describeElement(page, secondIdentifier)}`,
    });
  },
);

// For content that only exists inside a third-party iframe (a MailerLite
// sign-up pop-up, an embedded form), which page.$ can't see. Both keys are
// mappings: the iframe itself, and the element inside it. Confirmed live on
// HIB (2026-09-29): the footer's "Subscribe" link opens MailerLite's form
// in an iframe, with the email field only reachable through the frame.
Then(
  /^the "([^"]*)" inside the "([^"]*)" iframe should be displayed$/,
  async function (this: ScenarioWorld, elementKey: string, iframeKey: string) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const iframeIdentifier = getElementLocator(page, iframeKey, globalConfig);
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await expect(
      page.frameLocator(iframeIdentifier).locator(elementIdentifier).first(),
      `"${elementKey}" (${elementIdentifier}) inside the "${iframeKey}" iframe (${iframeIdentifier}) to be displayed`,
    ).toBeVisible({ timeout: 15000 });
  },
);

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
Then(
  /^the "([^"]*)" should\s*(not)?\s*be displayed$/,
  async function (this: ScenarioWorld, elementKey: string, negate: boolean) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const isElementVisible = (await page.$(elementIdentifier)) != null;
      return isElementVisible === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not be present" : "be displayed"}`,
      describeActual: () => describeElement(page, elementIdentifier),
    });
  },
);

// For in-page anchor links ("View all branches" -> #all-branches): the target
// is already "displayed" before the click, since it's rendered further down
// the page, so the displayed step can't tell whether the link did anything.
// Nor can a URL-hash check - confirmed live on Indespension's /branches
// (2026-09-29): the link scrolls correctly (scrollY 0 -> 1042) but Next.js
// never adds the hash to the URL. Asserting the target is inside the
// viewport tests the real behaviour.
Then(
  /^the "([^"]*)" should be scrolled into view$/,
  async function (this: ScenarioWorld, elementKey: string) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await expect(page.locator(elementIdentifier).first()).toBeInViewport({ timeout: 10000 });
  },
);

// For slow third-party widgets (e.g. an embedded Google Map, confirmed live on
// Indespension's /branches, 2026-09-29: ~10s before the map first draws) that
// can take longer than waitFor's default 15s budget on a slow run.
Then(
  /^the "([^"]*)" should be displayed within "(\d+)" seconds$/,
  // Explicit step budget: without it cucumber's own SCRIPT_TIMEOUT (20s on
  // several projects) cuts the wait off early - confirmed 2026-09-29, a
  // "within 30 seconds" step died at 20s. Supports up to 60s.
  { timeout: 65000 },
  async function (this: ScenarioWorld, elementKey: string, seconds: string) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => (await page.$(elementIdentifier)) != null, {
      timeout: Number(seconds) * 1000,
      expected: `"${elementKey}" (${elementIdentifier}) to be displayed within ${seconds}s`,
      describeActual: () => describeElement(page, elementIdentifier),
    });
  },
);

// "should not be displayed" passes the instant the element is absent, so it
// can't catch something that renders fine and THEN breaks. Confirmed live on
// Indespension's /branches (2026-09-29): the Google Map draws, then ~1s later
// Google swaps it for its "Oops! Something went wrong" error overlay - every
// existing branch-finder assertion had already passed by then. This watches
// for the whole window and fails as soon as the element shows up.
Then(
  /^the "([^"]*)" should not appear within "(\d+)" seconds$/,
  // Explicit step budget: without it cucumber's own SCRIPT_TIMEOUT (20s on
  // several projects) cuts the wait off early - confirmed 2026-09-29, a
  // "within 30 seconds" step died at 20s. Supports up to 60s.
  { timeout: 65000 },
  async function (this: ScenarioWorld, elementKey: string, seconds: string) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const deadline = Date.now() + Number(seconds) * 1000;

    while (Date.now() < deadline) {
      if ((await page.$(elementIdentifier)) != null) {
        const text = (await page.locator(elementIdentifier).first().innerText().catch(() => "")).replace(/\s+/g, " ").trim();
        throw new Error(`Expected: "${elementKey}" (${elementIdentifier}) not to appear within ${seconds}s Found: it appeared${text ? ` - "${text}"` : ""}`);
      }
      await page.waitForTimeout(250);
    }
  },
);

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
Then(
  /^the "([^"]*)" should\s*(not)?\s*be enabled$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    negate: boolean,
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const isElementEnabled = await page.isEnabled(elementIdentifier);
      return isElementEnabled === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to be ${negate ? "disabled" : "enabled"}`,
      describeActual: () => describeElement(page, elementIdentifier),
    });
  },
);

Then(
  /^I should( not)? see "([^"]*)" "([^"]*)" displayed$/,
  async function (
    this: ScenarioWorld,
    negate: boolean,
    count: string,
    elementKey: ElementKey,
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const element = await page.$$(elementIdentifier);
      return (count === String(element.length)) === !negate;
    }, {
      expected: `${negate ? "not " : ""}${count} "${elementKey}" (${elementIdentifier}) element(s) to be displayed`,
      describeActual: async () => `${(await page.$$(elementIdentifier)).length} matching element(s) found`,
    });
  },
);

// Remembers a live count instead of a hardcoded number, so tests against
// content that changes over time (product catalogues, search results) stay
// correct rather than asserting a snapshot-in-time total.
When(
  /^I remember the number of "([^"]*)" elements as "([^"]*)"$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    variableName: string,
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const elements = await page.$$(elementIdentifier);
    this.globalVariables[variableName] = String(elements.length);
  },
);

Then(
  /^the number of "([^"]*)" elements should (equal|be fewer than|be more than) the remembered "([^"]*)"$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    comparison: "equal" | "be fewer than" | "be more than",
    variableName: string,
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
      throw new Error(
        `No remembered count found for "${variableName}" - "I remember the number of ... elements as ..." must run first.`,
      );
    }
    const rememberedCount = Number(remembered);
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const currentCount = (await page.$$(elementIdentifier)).length;
      if (comparison === "equal") return currentCount === rememberedCount;
      if (comparison === "be fewer than") return currentCount < rememberedCount;
      return currentCount > rememberedCount;
    }, {
      expected: `number of "${elementKey}" (${elementIdentifier}) elements to ${comparison} the remembered count (${rememberedCount})`,
      describeActual: async () => `${(await page.$$(elementIdentifier)).length} matching element(s) found`,
    });
  },
);

// A true visibility check, unlike "should be displayed" above, which only
// checks the element is in the DOM. Needed for content that's always
// rendered but hidden until something happens (a multi-step form's later
// steps, a collapsed menu panel).
Then(
  /^the "([^"]*)" should( not)? be visible$/,
  async function (this: ScenarioWorld, elementKey: string, negate: string | undefined) {
    const {
      screen: { page },
      globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const locator = page.locator(elementIdentifier).first();

    if (negate) {
      await expect(locator, `"${elementKey}" (${elementIdentifier}) to be hidden`).toBeHidden({ timeout: 15000 });
    } else {
      await expect(locator, `"${elementKey}" (${elementIdentifier}) to be visible`).toBeVisible({ timeout: 15000 });
    }
  },
);
