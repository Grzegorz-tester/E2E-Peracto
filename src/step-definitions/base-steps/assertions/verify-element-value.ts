import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey, PageId } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { expect } from "@playwright/test";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { getValue } from "../../support-functions/html-behaviour";

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
      const elementText = await page.textContent(elementIdentifier);
      return elementText?.includes(user.email as string);
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
      const elementText = await page.textContent(elementIdentifier);

      return elementText?.includes(expectedElementText) === !negate;
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
      const elementText = await page.textContent(elementIdentifier);

      return (elementText?.trim() === expectedElementText.trim()) === !negate;
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

    await waitFor(async () => {
      const elementText = await page.textContent(
        `${elementIdentifier}>>nth=${index}`
      );
      return elementText?.includes(expectedElementText) === !negate;
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
      const currentText = await page.textContent(elementIdentifier);
      return (currentText?.trim() === remembered.trim()) === !negate;
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
      const currentText = await page.textContent(elementIdentifier);
      return (currentText?.includes(remembered) ?? false) === !negate;
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
    }, { timeout: 15000, wait: 500 });
  }
);
