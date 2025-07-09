import {Then} from "@cucumber/cucumber";
import {ScenarioWorld} from "../../setup/world";
import {ElementKey, PageId} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {expect} from "@playwright/test";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {getValue} from "../../support-functions/html-behaviour";


// the element should contain the text ( text content of the element)
Then(/^the "([^"]*)" should( not)? contain the text "([^"]*)"$/, async function
(this: ScenarioWorld, elementKey: ElementKey, negate: boolean, expectedElementText: string) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {

        const elementText = await page.textContent(elementIdentifier);

        return elementText?.includes(expectedElementText) === !negate;
    })
});

// the ( element ) should equal text ( text content of the element)
Then(/^the "([^"]*)" should( not)? equal text "([^"]*)"$/, async function
(this: ScenarioWorld, elementKey: ElementKey, negate: boolean, expectedElementText: string) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const elementText = await page.textContent(elementIdentifier);

        return (elementText === expectedElementText) === !negate;
    })

});

// the ( element ) should equal value ( value of the element)
Then(/^the "([^"]*)" should( not)? equal the value "([^"]*)"$/, async function
(elementKey: ElementKey, negate: boolean, elementValue: string) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const elementAttribute = await getValue(page, elementIdentifier);
        return (elementAttribute === elementValue) === !negate;
    });
});


// he should be presented with a ( message locator ) ( text content of the message )
Then(/^I should be presented with a "([^"]*)" "([^"]*)"$/, async function
(this: ScenarioWorld, elementKey: ElementKey, expectedElementText: string) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    const elementText = await page.textContent(elementIdentifier);

    expect(elementText).toContain(expectedElementText);
});


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
            screen: {page},
            globalConfig,
        } = this;

        console.log(
            `the ${elementPosition} ${elementKey} should ${negate ? 'not ' : ''}contain the text ${expectedElementText}`
        );

        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
        const index = Number(elementPosition.match(/\d/g)?.join('')) - 1;

        await waitFor(async () => {
            const elementText = await page.textContent(`${elementIdentifier}>>nth=${index}`);
            return elementText?.includes(expectedElementText) === !negate;
        });
    }
);