import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
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
    });
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
    });
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
    });
  },
);
