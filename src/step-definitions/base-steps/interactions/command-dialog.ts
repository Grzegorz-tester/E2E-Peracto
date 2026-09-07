import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";

// For a cmdk-style "Command Dialog" combobox - a plain trigger button that
// opens a role="dialog" popup containing a filterable, searchable list of
// role="option" items - a distinct shape from both the Radix listbox
// (button[role='combobox'] trigger, role='listbox' popup) and react-select
// steps already in this framework (see form.ts), neither of which matches
// here. VERIFIED live on Russells' Quick Parts Finder (staging, 2026-08-02):
// trigger buttons carry no role="combobox" of their own, and the popup is
// role="dialog" (not role="listbox"). The dialog selector is hardcoded
// (not config-driven) since it's the same third-party/structural-pattern
// selector regardless of project, the same convention this framework
// already uses for e.g. the mailerlite newsletter popup's iframe. Composes
// with "I search for ... in the currently open command dialog" and "I
// select the ... option from the currently open command dialog" below, so
// a scenario can open, optionally filter, then either select or assert an
// empty state - reusable by any project with the same cmdk/Command Dialog
// pattern (a common shadcn/cmdk UI shape likely to recur).
When(/^I open the "([^"]*)" command dialog$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const triggerSelector = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(triggerSelector, { state: "visible", timeout: 15000 });
    await page.click(triggerSelector);
    await page.waitForSelector("[role='dialog']:not(#ckyPreferenceCenter)", { state: "visible", timeout: 15000 });
});

When(/^I search for "([^"]*)" in the currently open command dialog$/, async function (this: ScenarioWorld, searchTerm: string) {
    const { screen: { page } } = this;
    const dialogSearchInput = page.locator("[role='dialog']:not(#ckyPreferenceCenter) input");

    await dialogSearchInput.waitFor({ state: "visible", timeout: 15000 });
    await dialogSearchInput.fill(searchTerm);
});

When(/^I select the "([^"]*)" option from the currently open command dialog$/, async function (this: ScenarioWorld, option: string) {
    const { screen: { page } } = this;
    const dialog = page.locator("[role='dialog']:not(#ckyPreferenceCenter)");

    await dialog.locator("[role='option']").first().waitFor({ state: "visible", timeout: 15000 });
    await dialog.getByText(option, { exact: true }).click();
    await dialog.waitFor({ state: "hidden", timeout: 15000 });
});
