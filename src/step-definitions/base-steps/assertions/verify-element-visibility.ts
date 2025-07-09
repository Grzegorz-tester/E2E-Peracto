import {Then} from "@cucumber/cucumber";
import {ScenarioWorld} from "../../setup/world";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {expect} from "@playwright/test";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {ElementKey} from "../../../env/global";

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
Then(/^the "([^"]*)" should\s*(not)?\s*be displayed$/, async function (this: ScenarioWorld, elementKey: string, negate: boolean) {
    const {
        screen: {page},
        globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {

        const isElementVisible = (await page.$(elementIdentifier)) != null;
        return isElementVisible === !negate;
    })
});

// this regex \s*(not)?\s* allows to use it in the Examples when there is an empty string
Then(/^the "([^"]*)" should\s*(not)?\s*be enabled$/, async function (this: ScenarioWorld, elementKey: ElementKey, negate: boolean) {
        const {
            screen: {page},
            globalConfig,
        } = this;

        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

        await waitFor(async () => {
            const isElementEnabled = await page.isEnabled(elementIdentifier);
            return isElementEnabled === !negate;
        });
    }
);

Then(/^I should( not)? see "([^"]*)" "([^"]*)" displayed$/,
    async function (this: ScenarioWorld, negate: boolean, count: string, elementKey: ElementKey) {
        const {
            screen: {page},
            globalConfig,
        } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig)

        await waitFor(async () => {
            const element = await page.$$(elementIdentifier)
            return (count === String(element.length)) === !negate;
        });
    }
);


