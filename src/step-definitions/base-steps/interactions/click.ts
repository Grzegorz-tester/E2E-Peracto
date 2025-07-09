import {Given, When} from "@cucumber/cucumber";
import {ElementKey} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {clickElement, clickElementAtIndex} from "../../support-functions/html-behaviour";
import {ScenarioWorld} from "../../setup/world";

When(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig)
    const result = await waitFor(async () => elementIdentifier, {
        state: "visible",
    });
    if (result) {
        await new Promise(resolve => setTimeout(resolve, 300));
        await clickElement(page, elementIdentifier);
    }
    return result;
});


When(/^I slowly click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig)
    const result = await waitFor(async () => elementIdentifier, {
        state: "visible",
    });
    if (result) {
        await new Promise(resolve => setTimeout(resolve, 6000));
        await clickElement(page, elementIdentifier);
    }
    return result;
});

When(
    /^I click the "([0-9]+th|[0-9]+st|[0-9]+nd|[0-9]+rd)" "([^"]*)" (?:button|link|element)$/,
    async function (this: ScenarioWorld, elementPosition: string, elementKey: ElementKey) {
        const {screen: {page}, globalConfig} = this;

        // Get the element locator
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

        // Extract the numeric part of the position and convert to zero-based index
        const pageIndex = Number(elementPosition.match(/\d+/)?.[0]) - 1;

        // Wait for the element to be visible and click it
        await waitFor(async () => {
            const result = await page.waitForSelector(elementIdentifier, {
                state: 'visible',
            });
            if (result) {
                await clickElementAtIndex(page, elementIdentifier, pageIndex);
            }
            return result;
        });
    }
);
