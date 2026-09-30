import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { enterValue } from "../../support-functions/html-behaviour";
import { ElementKey } from "../../../env/global";

// CONFIRMED (live, Carbon Admin staging, 2026-09-18): an Attribute's Code
// auto-generates from its Label on blur, same as content's slug or a
// Category's Identifier - but unlike those, Peracto rejects a Code
// containing a hyphen ("Attributes Codes can not begin with a number and
// can only contain letters, numbers and underscores"). The shared
// "... with a unique test title" step's own readable timestamp
// (content-admin.ts, "2026-09-18 09:23:42") slugifies its spaces into
// underscores but leaves the date's hyphens in place, so relying on
// auto-generation from that value fails Save outright every time - not a
// timing race, a genuine validation mismatch (it looked identical to one
// at first: no toast, no redirect, because the save was silently
// rejected). Filling any Code-shaped field explicitly with a hyphen-free
// value sidesteps auto-generation entirely - reused as-is for Shipping
// Service's own Code field too, which needs the same treatment.
When(/^I fill in the "([^"]*)" input field with a unique code$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;

    const code = `velstar_test_code_${Date.now()}`;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await page.waitForSelector(elementIdentifier, { state: "visible", timeout: 15000 });
    await enterValue(page, elementIdentifier, code);
});
