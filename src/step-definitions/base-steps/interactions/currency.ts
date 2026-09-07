import { When } from "@cucumber/cucumber";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { clickElement } from "../../support-functions/html-behaviour";

// The currency picker is a header dropdown: click the toggle to reveal the
// GBP/EUR options, then click the requested one.
When(/^I switch the currency to "(GBP|EUR)"$/, async function (currency: "GBP" | "EUR") {
    const {
        screen: { page },
        globalConfig,
    } = this;

    const toggleLocator = getElementLocator(page, "currency picker", globalConfig);
    await clickElement(page, toggleLocator, { timeout: 15000 });

    const optionLocator = getElementLocator(page, `${currency} currency option`, globalConfig);
    await page.waitForSelector(optionLocator, { state: "visible", timeout: 10000 });
    await clickElement(page, optionLocator, { timeout: 10000 });
});
