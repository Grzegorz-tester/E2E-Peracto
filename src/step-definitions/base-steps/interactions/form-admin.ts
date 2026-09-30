import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { enterValue } from "../../support-functions/html-behaviour";
import { ElementKey } from "../../../env/global";

// Same "Velstar Test <Entity> <ts>" identifiability convention as
// product-admin.ts's "unique product name" - so an orphaned Form/Form
// Field left behind by a failed delete step (as happened with Lamona's
// leftover "Velstar Test Product" rows) is immediately recognisable as our
// own disposable test data in a client's real admin, not guessed at later.
When(/^I fill in the "([^"]*)" input field with a unique form label$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const formLabel = `Velstar Test Form ${Date.now()}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await enterValue(page, elementIdentifier, formLabel);

    this.globalVariables["form label"] = formLabel;
});

When(/^I fill in the "([^"]*)" input field with a unique form field label$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const formFieldLabel = `Velstar Test Field ${Date.now()}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await enterValue(page, elementIdentifier, formFieldLabel);

    this.globalVariables["form field label"] = formFieldLabel;
});
