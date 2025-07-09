import {When} from "@cucumber/cucumber";
import {ElementKey} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {enterValue, selectDropdownOption} from "../../support-functions/html-behaviour";

When(/^I fill in the "([^"]*)" input field with "([^"]*)"$/, async function (elementKey: ElementKey, inputText: string) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const result = await page.waitForSelector(elementIdentifier, {
        });
        if (result) {
            await enterValue(page, elementIdentifier, inputText);
        }
        return result;
    })
});


When(/^I select the "([^"]*)" option from the "([^"]*)" dropdown$/, async function (option: string, elementKey: ElementKey) {
    const {
        screen: {page},

        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const result = await page.waitForSelector(elementIdentifier, {
            state: "visible"
        });

        if (result) {
            await selectDropdownOption(page, elementIdentifier, option);
        }
    })
});