import { Then } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { expect } from "@playwright/test";
import { ElementKey } from "../../../env/global";

// Checks the asset's own HTTP response rather than just "the <img> element
// is visible" - a broken/expired CDN URL can still render an <img> element
// with no visible layout break. Uses GET rather than HEAD since some CDNs
// (confirmed on other projects' image hosts) don't support HEAD and 404 it
// even when the resource itself is fine.
Then(
    /^the "([^"]*)" image should return a 200 OK response with content-type "([^"]*)"$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, expectedContentType: string) {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

        const src = await page.getAttribute(elementIdentifier, "src");
        if (!src) {
            throw new Error(`"${elementKey}" (${elementIdentifier}) has no "src" attribute to check.`);
        }
        const url = new URL(src, page.url()).toString();

        const response = await page.request.get(url, { timeout: 15000 });
        expect(response.status(), `${url} -> ${response.status()}`).toBe(200);
        expect(response.headers()["content-type"] ?? "").toContain(expectedContentType);
    }
);

// Fetches a path remembered earlier in the scenario (e.g. a share link's
// href) directly, rather than navigating to it - navigating to a URL that
// serves an attachment makes Playwright's goto() throw "Download is
// starting". Uses the page's own request context, so it carries the
// current session (or the lack of one, after logging out), which is what
// "can someone without a login open this link" checks need.
Then(
    /^requesting the remembered path "([^"]*)" should return status (\d+)(?: with content-type "([^"]*)")?$/,
    async function (this: ScenarioWorld, variableName: string, expectedStatus: string, expectedContentType: string | undefined) {
        const { screen: { page } } = this;
        const urlPath = this.globalVariables[variableName];
        if (urlPath === undefined) {
            throw new Error(`No remembered path found for "${variableName}".`);
        }
        const url = new URL(urlPath, page.url()).toString();

        const response = await page.request.get(url, { timeout: 15000, maxRedirects: 0 });
        expect(response.status(), `${url} -> ${response.status()}`).toBe(Number(expectedStatus));
        if (expectedContentType !== undefined) {
            expect(response.headers()["content-type"] ?? "").toContain(expectedContentType);
        }
    }
);
