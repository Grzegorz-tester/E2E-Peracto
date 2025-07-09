import {When} from "@cucumber/cucumber";
import {ElementKey} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {checkElement} from "../../support-functions/html-behaviour";

When(/^I check the "([^"]*)"$/, async function (elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const result = await page.waitForSelector(elementIdentifier, {
            state: "visible",
        })
        if (result) {
            await checkElement(page, elementIdentifier);
        }
        return result;
    })
});