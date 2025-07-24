import { Given, When } from "@cucumber/cucumber";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import {
  clickElement,
  clickElementAtIndex,
} from "../../support-functions/html-behaviour";
import { ScenarioWorld } from "../../setup/world";

When(
  /^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/,
  async function (elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const result = await waitFor(async () => elementIdentifier, {
      state: "visible",
    });
    if (result) {
      await new Promise((resolve) => setTimeout(resolve, 300));
      await clickElement(page, elementIdentifier);
    }
    return result;
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
    const result = await waitFor(async () => elementIdentifier, {
      state: "visible",
    });
    if (result) {
      await new Promise((resolve) => setTimeout(resolve, 6000));
      await clickElement(page, elementIdentifier);
    }
    return result;
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

    await waitFor(async () => {
      const result = await page.waitForSelector(elementIdentifier, {
        state: "visible",
      });
      if (result) {
        await clickElementAtIndex(page, elementIdentifier, index);
      }
      return result;
    });
  }
);
