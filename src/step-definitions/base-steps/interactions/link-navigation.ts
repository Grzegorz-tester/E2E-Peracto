import { Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";

// For a link whose destination is entirely dynamic (real catalog/CMS data,
// or even a different origin entirely - e.g. a CDN asset) and so has no
// fixed PageId to assert against afterwards. Captures the resulting
// navigation's response status instead, which works regardless of where the
// link actually leads.
//
// Matches by origin+pathname only, ignoring the query string entirely - a
// third-party analytics script (confirmed live: HubSpot) rewrites outbound
// links' href with fresh tracking query params (__hstc/__hssc/__hsfp,
// timestamp-based) independently of this step's own read of the attribute,
// so the exact query string at click time is a moving target and an
// unreliable thing to match on; the path is stable. decodeURI() tolerates a
// raw, unencoded space in an href that the real network request still
// percent-encodes, wrapped in a try/catch since an unrelated third-party
// request's malformed query string can otherwise throw a URIError and abort
// the whole wait. A generous, explicit timeout (passed to the step
// registration, not just the internal wait) gives a slow external asset
// (e.g. a CDN-hosted image on a real, uncached first load) enough headroom
// to still resolve within this step, rather than being cut off by this
// framework's global default step timeout.
When(/^I click on the "([^"]*)" element and note the response status$/, { timeout: 40000 }, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const {
        screen: { page },
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const element = page.locator(elementIdentifier);
    const href = await element.getAttribute("href");
    if (!href) {
        throw new Error(`"${elementKey}" has no href to wait a navigation response for.`);
    }

    const pathOf = (url: string) => {
        try {
            const parsed = new URL(url, page.url());
            return decodeURI(parsed.origin + parsed.pathname);
        } catch {
            return url.split("?")[0];
        }
    };
    const hrefPath = pathOf(href);

    const [response] = await Promise.all([
        page.waitForResponse((res) => pathOf(res.url()) === hrefPath, { timeout: 35000 }),
        element.click(),
    ]);

    this.globalVariables["noted response status"] = String(response.status());
});

Then(/^the noted response status should be less than (\d+)$/, async function (this: ScenarioWorld, thresholdText: string) {
    const status = this.globalVariables["noted response status"];
    if (status === undefined) {
        throw new Error(`No noted response status found - "I click on ... and note the response status" must run first.`);
    }
    const threshold = Number(thresholdText);
    if (!(Number(status) < threshold)) {
        throw new Error(`Expected the noted response status (${status}) to be less than ${threshold}.`);
    }
});

// cucumber-js auto-converts a purely-numeric regex capture group to a
// Number, not a string - accept either here rather than relying on which
// one gets passed.
Then(/^the noted response status should equal (\d+)$/, async function (this: ScenarioWorld, expected: string | number) {
    const status = this.globalVariables["noted response status"];
    if (status === undefined) {
        throw new Error(`No noted response status found - "I click on ... and note the response status" must run first.`);
    }
    if (Number(status) !== Number(expected)) {
        throw new Error(`Expected the noted response status to equal ${expected}, got ${status}.`);
    }
});

// For a destination page with no PageId of its own (e.g. a dynamic/CMS
// branch page reached through an arbitrary link) - checks by visible
// heading text directly, bypassing the pageId-based element-mapping layer
// entirely, since getCurrentPageId would otherwise throw for a route with
// no matching pagesConfig entry.
Then(/^a heading with the text "([^"]*)" should be displayed$/, async function (this: ScenarioWorld, text: string) {
    const { screen: { page } } = this;
    await expect(page.getByRole("heading", { name: text, exact: true })).toBeVisible({ timeout: 15000 });
});
