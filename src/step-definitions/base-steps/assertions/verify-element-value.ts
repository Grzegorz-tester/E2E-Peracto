import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey, PageId } from "../../../env/global";
import { describeElement, getElementLocator } from "../../support-functions/web-element-helper";
import { expect } from "@playwright/test";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { getValue } from "../../support-functions/html-behaviour";

// Every page.textContent(elementIdentifier) call below inside a waitFor poll
// (and its matching describeActual) passes an explicit short timeout - same
// fix already applied in admin-tasks.ts's readToast() helper, and for the
// exact same reason. CONFIRMED (live, MIPA_ADMIN_RELEASE 2.8.0, 2026-09-09):
// when the target element genuinely never appears (e.g. asserting on a
// "response details" panel that never renders because the real call failed
// via a toast instead), a bare page.textContent() auto-waits for Playwright's
// own default actionability timeout (~30s) before resolving to null - so a
// single poll iteration can burn most or all of a step's own Cucumber
// timeout, surfacing as an opaque "function timed out" instead of this
// framework's own clear "Expected: X, Found: Y" message. A short per-call
// timeout with a null fallback keeps every poll fast regardless of whether
// the element is ever going to show up, letting waitFor's own retry loop
// (and its proper error reporting) actually run to completion.

// Sources the expected email from users.json/env vars instead of literal
// Gherkin text, so real account emails never need to be hardcoded in a
// .feature file.
Then(
  /^the "([^"]*)" should contain the "([^"]*)" user's email$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    userType: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const user = globalConfig.usersConfig[userType.trim().toLowerCase()];
    if (!user?.email) {
      throw new Error(`Missing email for user type "${userType}". Check your users.json and env vars.`);
    }

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const elementText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
      return elementText?.includes(user.email as string);
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to contain the ${userType} user's email "${user.email}"`,
      describeActual: async () => `text was "${(await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null))?.trim() ?? "(could not read text)"}"`,
    });
  }
);

// the element should contain the text ( text content of the element)
Then(
  /^the "([^"]*)" should( not)? contain the text "(.*)"$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    negate: boolean,
    expectedElementText: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const elementText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);

      return elementText?.includes(expectedElementText) === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}contain the text "${expectedElementText}"`,
      describeActual: async () => `text was "${(await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null))?.trim() ?? "(could not read text)"}"`,
    });
  }
);

// the ( element ) should equal text ( text content of the element)
Then(
  /^the "([^"]*)" should( not)? equal text "([^"]*)"$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    negate: boolean,
    expectedElementText: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    // textContent() includes incidental whitespace from surrounding markup
    // indentation/line breaks (confirmed live on Watco: a validation
    // message wrapped in <ul><li> renders as "\n  text\n" via textContent
    // even though only "text" is visually shown) - trimming both sides
    // matches what a Gherkin author actually means by "equal text".
    await waitFor(async () => {
      const elementText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);

      return (elementText?.trim() === expectedElementText.trim()) === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}equal text "${expectedElementText}"`,
      describeActual: async () => `text was "${(await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null))?.trim() ?? "(could not read text)"}"`,
    });
  }
);

// the ( element ) should equal value ( value of the element)
Then(
  /^the "([^"]*)" should( not)? equal the value "([^"]*)"$/,
  async function (
    elementKey: ElementKey,
    negate: boolean,
    elementValue: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const elementAttribute = await getValue(page, elementIdentifier);
      return (elementAttribute === elementValue) === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}equal the value "${elementValue}"`,
      describeActual: async () => `value was "${(await getValue(page, elementIdentifier).catch(() => null)) ?? "(could not read value)"}"`,
    });
  }
);

// he should be presented with a ( message locator ) ( text content of the message )
Then(
  /^I should be presented with a "([^"]*)" "([^"]*)"$/,
  async function (
    this: ScenarioWorld,
    elementKey: ElementKey,
    expectedElementText: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    const elementText = await page.textContent(elementIdentifier);

    expect(elementText).toContain(expectedElementText);
  }
);

//the ( container ) should contain ( amount of items ) ( item )
// Then(/^the "([^"]*)" should contain "([^"]*)" "([^"]*)"$/, async function (
//     containerElementKey: ElementKey,
//     amount: number,
//     itemElementKey: ElementKey) {
//
// });

Then(
  /^the "([0-9]+th|[0-9]+st|[0-9]+nd|[0-9]+rd)" "([^"]*)" should( not)? contain the text "(.*)"$/,
  async function (
    elementPosition: string,
    elementKey: ElementKey,
    negate: boolean,
    expectedElementText: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    console.log(
      `the ${elementPosition} ${elementKey} should ${
        negate ? "not " : ""
      }contain the text ${expectedElementText}`
    );

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const index = Number(elementPosition.match(/\d/g)?.join("")) - 1;
    const indexedIdentifier = `${elementIdentifier}>>nth=${index}`;

    await waitFor(async () => {
      const elementText = await page.textContent(indexedIdentifier, { timeout: 1000 }).catch(() => null);
      return elementText?.includes(expectedElementText) === !negate;
    }, {
      expected: `the ${elementPosition} "${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}contain the text "${expectedElementText}"`,
      describeActual: () => describeElement(page, indexedIdentifier),
    });
  }
);

// Remembers live text instead of a hardcoded value, so tests against content
// that changes over time (e.g. which product sorts first) can assert "this
// changed" rather than asserting a specific snapshot-in-time value.
When(
  /^I remember the text of "([^"]*)" as "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const text = await page.textContent(elementIdentifier);
    this.globalVariables[variableName] = text ?? "";
  }
);

// For a value that's usually present but can legitimately be blank on one
// particular candidate - confirmed live: Carbon Admin's own Products list
// has a genuinely blank-named seed row at position 0 (its SKU is
// populated, just not its name), which would otherwise make "remember the
// text of ... as ..." stash an empty string for any shared scenario that
// assumes row 0 is usable. elementKey should resolve to ALL candidates
// (e.g. every row's own name cell, not just row 0's), same convention as
// click.ts's "the first enabled ..." step - this remembers whichever one
// actually has text, mirroring that step's same "not every candidate is
// usable" reasoning for reading text instead of clicking.
//
// Deliberately waits for at least one candidate to be ATTACHED, not for
// candidates.first() to be VISIBLE - confirmed live, this is another
// symptom of Carbon Admin's own confirmed 0x0-bounding-box bug on its
// Products list's first row link (see first-item-redirects.feature):
// that row genuinely never becomes "visible" to Playwright, so waiting on
// first() specifically would time out there even though later candidates
// (row 1, 2, ...) are perfectly visible and exactly what this step exists
// to fall through to.
When(
  /^I remember the text of the first non-empty "([^"]*)" as "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const candidates = page.locator(elementIdentifier);
    await candidates.first().waitFor({ state: "attached", timeout: 15000 });

    const count = await candidates.count();
    for (let i = 0; i < count; i++) {
      const text = (await candidates.nth(i).textContent())?.trim();
      if (text) {
        this.globalVariables[variableName] = text;
        return;
      }
    }
    throw new Error(`None of the ${count} "${elementKey}" (${elementIdentifier}) candidates have any text.`);
  }
);

// A "first match" variant of the above - for a candidate list where some
// entries are legitimate but not usable for the scenario at hand (e.g. a
// manually-seeded QA/test row mixed in among real ones), rather than one
// that's simply blank. CONFIRMED (live, MIPA_ADMIN_RELEASE 2.8.0,
// 2026-09-08): the Products list's row 0 can be a dummy product created
// directly on an environment for manual testing (name AND "SKU" both
// literally "test may"), which isn't synced to the real ERP - the "first
// non-empty" step above would happily remember it since it's non-blank,
// but it isn't a real SKU. Callers supply their own pattern (e.g.
// "^\\d+$" for a numeric-only SKU) rather than this step assuming what
// "real" looks like, so it stays reusable beyond just SKUs.
When(
  /^I remember the text of the first "([^"]*)" matching the pattern "([^"]*)" as "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, pattern: string, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const candidates = page.locator(elementIdentifier);
    await candidates.first().waitFor({ state: "attached", timeout: 15000 });

    const regex = new RegExp(pattern);
    const count = await candidates.count();
    for (let i = 0; i < count; i++) {
      const text = (await candidates.nth(i).textContent())?.trim();
      if (text && regex.test(text)) {
        this.globalVariables[variableName] = text;
        return;
      }
    }
    throw new Error(`None of the ${count} "${elementKey}" (${elementIdentifier}) candidates match the pattern "${pattern}".`);
  }
);

// For a link or other attribute value only known at runtime (e.g. a
// generated share link's href), to revisit or request it later in the
// same scenario.
When(
  /^I remember the "([^"]*)" attribute of the "([^"]*)" as "([^"]*)"$/,
  async function (this: ScenarioWorld, attribute: string, elementKey: ElementKey, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.waitForSelector(elementIdentifier, { state: "attached", timeout: 15000 });
    const value = await page.getAttribute(elementIdentifier, attribute);
    if (value === null) {
      throw new Error(`"${elementKey}" (${elementIdentifier}) has no "${attribute}" attribute.`);
    }
    this.globalVariables[variableName] = value;
  }
);

// For a value embedded in a longer text, where only that part is useful
// later (e.g. the postcode at the end of a one-line address, to search by
// postcode on its own). Remembers the first regex match - or its first
// capture group, if the pattern has one - rather than the whole text.
When(
  /^I remember the part of the "([^"]*)" text matching the pattern "([^"]*)" as "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, pattern: string, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    await page.waitForSelector(elementIdentifier, { state: "attached", timeout: 15000 });
    const text = (await page.textContent(elementIdentifier))?.trim() ?? "";
    const match = text.match(new RegExp(pattern));
    if (!match) {
      throw new Error(`"${elementKey}" (${elementIdentifier}) text "${text}" does not match the pattern "${pattern}".`);
    }
    this.globalVariables[variableName] = match[1] ?? match[0];
  }
);

// For a value that renders with an extra prefix in one place but not
// another (e.g. a PDP shows "SKU 12345" while the basket line for the same
// product shows plain "12345") - stripping the prefix at remember-time
// means a later "should contain the remembered" assertion compares the two
// on equal footing instead of always failing in one direction.
When(
  /^I remember the text of "([^"]*)" with the prefix "([^"]*)" stripped, as "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, prefix: string, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const text = await page.textContent(elementIdentifier);
    const stripped = (text ?? "").replace(new RegExp(`^${prefix}\\s*`), "");
    this.globalVariables[variableName] = stripped;
  }
);

Then(
  /^the "([^"]*)" text should( not)? equal the remembered "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, negate: boolean, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
      throw new Error(`No remembered text found for "${variableName}" - "I remember the text of ... as ..." must run first.`);
    }
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const currentText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
      return (currentText?.trim() === remembered.trim()) === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}equal the remembered text "${remembered}"`,
      describeActual: async () => `text was "${(await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null))?.trim() ?? "(could not read text)"}"`,
    });
  }
);

// A "contains" variant of the above - for cases where the remembered text is
// only a substring of what the target element ends up showing (e.g. a PDP's
// "SKU 12345" vs a basket line's plain "12345"), where an exact match would
// never hold even though the value is genuinely the same.
Then(
  /^the "([^"]*)" should( not)? contain the remembered "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, negate: boolean, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
      throw new Error(`No remembered text found for "${variableName}" - "I remember the text of ... as ..." must run first.`);
    }
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const currentText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
      return (currentText?.includes(remembered) ?? false) === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}contain the remembered text "${remembered}"`,
      describeActual: async () => `text was "${(await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null))?.trim() ?? "(could not read text)"}"`,
    });
  }
);

// A case-insensitive variant of "should contain the remembered" above - for
// a value a real backend normalises the case of before echoing it back.
// Confirmed live on MIPA's Send Order test harness: a "qa-<timestamp>"
// unique value (this suite's standard disposable-value format) comes back
// from Business Central as "QA-<timestamp>" - genuinely the same value,
// just uppercased by BC itself, not a broken echo.
Then(
  /^the "([^"]*)" should( not)? contain the remembered "([^"]*)", case-insensitively$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, negate: boolean, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
      throw new Error(`No remembered text found for "${variableName}" - "I remember the text of ... as ..." must run first.`);
    }
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const currentText = await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null);
      return (currentText?.toLowerCase().includes(remembered.toLowerCase()) ?? false) === !negate;
    }, {
      expected: `"${elementKey}" (${elementIdentifier}) to ${negate ? "not " : ""}contain the remembered text "${remembered}" (case-insensitively)`,
      describeActual: async () => `text was "${(await page.textContent(elementIdentifier, { timeout: 1000 }).catch(() => null))?.trim() ?? "(could not read text)"}"`,
    });
  }
);

// An "any match" variant of "should contain the remembered" above - for a
// remembered value that could land in ANY ONE of several matching elements
// (e.g. one address card among several a user already has) rather than
// necessarily the first, which is all "should contain the remembered"
// checks (it reads only the first match's text). Also doubles as the
// negated "no longer present" check after a delete, since a genuinely
// empty result set makes the positive form meaningless the same way "the X
// should not be displayed" differs from "the X should be displayed".
Then(
  /^the remembered "([^"]*)" should\s*(not)?\s*appear in the "([^"]*)" element$/,
  async function (this: ScenarioWorld, variableName: string, negate: boolean, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
      throw new Error(`No remembered text found for "${variableName}" - "I remember the text of ... as ..." (or an equivalent "remembering it as ..." step) must run first.`);
    }
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
      const count = await page.locator(elementIdentifier).filter({ hasText: remembered }).count();
      return (count > 0) === !negate;
    }, {
      expected: `at least one "${elementKey}" (${elementIdentifier}) element to ${negate ? "not " : ""}contain the remembered "${variableName}" ("${remembered}")`,
      describeActual: async () => `found ${await page.locator(elementIdentifier).count()} matching element(s)${negate ? ", still" : ", none"} containing "${remembered}"`,
    });
  }
);

// Eventually-consistent check that EVERY matching element contains the given
// substring - for a list whose items settle asynchronously (e.g. a debounced
// search result set), rather than a single-shot read that can catch a
// mid-render/transitional state.
Then(
  /^the "([^"]*)" should all contain the text "([^"]*)"$/,
  async function (this: ScenarioWorld, elementKey: ElementKey, expectedText: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await waitFor(async () => {
      const elements = await page.$$(elementIdentifier);
      if (elements.length === 0) return false;
      const texts = await Promise.all(elements.map((el) => el.textContent()));
      return texts.every((text) => text?.toLowerCase().includes(expectedText.toLowerCase()));
    }, {
      timeout: 15000,
      wait: 500,
      expected: `every "${elementKey}" (${elementIdentifier}) element to contain the text "${expectedText}"`,
      describeActual: async () => {
        const elements = await page.$$(elementIdentifier);
        const texts = await Promise.all(elements.map((el) => el.textContent().catch(() => null)));
        return `${elements.length} matching element(s), texts: ${JSON.stringify(texts.map((t) => t?.trim()))}`;
      },
    });
  }
);
