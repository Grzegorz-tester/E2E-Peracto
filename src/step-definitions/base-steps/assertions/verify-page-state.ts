import { Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// Generic page-level checks first needed for Benchmarx's Next.js 15 upgrade
// regression (BEN-379, 2026-11-11), where the risk is the framework itself
// rather than any one component: status codes, document head, history,
// client-side routing and scroll locking. None of it is Benchmarx-specific.

const hostUrl = (world: ScenarioWorld, urlPath: string) => {
    const { UI_AUTOMATION_HOST: hostName = "release_branch" } = process.env;
    return new URL(urlPath, world.globalConfig.hostsConfig[hostName]).toString();
};

// Requests a path on the configured host without opening it in the browser,
// so a "soft 404" (a not-found page served with 200, which search engines
// index) is caught: the rendered page looks identical either way. Redirects
// are not followed, so a 301/308 is reported as itself.
// CONFIRMED (2026-11-11): Benchmarx next-15 serves /kitchens/does-not-exist
// with 200 where staging (Next 14) returns 404.
Then(
    /^requesting the path "([^"]*)" should return status (\d+)$/,
    async function (this: ScenarioWorld, urlPath: string, expectedStatus: string) {
        const url = hostUrl(this, urlPath);
        const response = await this.screen.page.request.get(url, { timeout: 30000, maxRedirects: 0 });
        expect(response.status(), `${url} -> ${response.status()}`).toBe(Number(expectedStatus));
    }
);

// For a plain-text resource such as robots.txt.
Then(
    /^the response body of the path "([^"]*)" should( not)? contain "([^"]*)"$/,
    async function (this: ScenarioWorld, urlPath: string, negate: string | null, expectedText: string) {
        const url = hostUrl(this, urlPath);
        const response = await this.screen.page.request.get(url, { timeout: 30000 });
        const body = await response.text();
        expect(response.status(), `${url} -> ${response.status()}`).toBeLessThan(400);
        expect(body.includes(expectedText), `${url} body ${negate ? "contains" : "does not contain"} "${expectedText}". Starts with: ${body.slice(0, 300)}`).toBe(!negate);
    }
);

Then(
    /^the page title should( not)? contain "([^"]*)"$/,
    async function (this: ScenarioWorld, negate: string | null, expectedText: string) {
        const { page } = this.screen;
        await waitFor(async () => (await page.title()).includes(expectedText) === !negate, {
            expected: `page title to ${negate ? "not " : ""}contain "${expectedText}"`,
            describeActual: async () => `page title is "${await page.title()}"`,
        });
    }
);

// Head tags (canonical, meta description, og:*, JSON-LD) are never
// "visible", so the usual visibility-based steps can't see them. Checks the
// element exists and its attribute (or, for a <script>, its text) is not
// blank.
Then(
    /^the "([^"]*)" head tag should have a non-empty "([^"]*)"$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, attribute: string) {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
        let actual: string | null = null;
        await waitFor(async () => {
            const element = page.locator(elementIdentifier).first();
            if (await element.count() === 0) return false;
            actual = attribute === "text" ? await element.textContent() : await element.getAttribute(attribute);
            return !!actual && actual.trim().length > 0;
        }, {
            expected: `"${elementKey}" (${elementIdentifier}) to exist with a non-empty ${attribute}`,
            describeActual: async () => `${attribute} was ${JSON.stringify(actual)}`,
        });
    }
);

// The canonical should point at the page being viewed on the host being
// tested (not, say, a hardcoded production or staging URL, or the homepage).
Then(
    /^the "([^"]*)" head tag's "([^"]*)" should match the current URL path$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, attribute: string) {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
        const current = new URL(page.url());
        let actual: string | null = null;
        await waitFor(async () => {
            actual = await page.locator(elementIdentifier).first().getAttribute(attribute).catch(() => null);
            if (!actual) return false;
            const target = new URL(actual, current);
            return target.host === current.host && target.pathname.replace(/\/$/, "") === current.pathname.replace(/\/$/, "");
        }, {
            expected: `"${elementKey}" ${attribute} to point at ${current.origin}${current.pathname}`,
            describeActual: async () => `${attribute} was ${JSON.stringify(actual)}`,
        });
    }
);

// Every <script type="application/ld+json"> on the page must parse.
Then(/^every JSON-LD block on the page should be valid JSON$/, async function (this: ScenarioWorld) {
    const blocks = await this.screen.page.locator("script[type='application/ld+json']").allTextContents();
    expect(blocks.length, "No JSON-LD blocks found on the page").toBeGreaterThan(0);
    const broken = blocks.filter((block) => {
        try { JSON.parse(block); return false; } catch { return true; }
    });
    expect(broken, `Unparseable JSON-LD:\n${broken.map((b) => b.slice(0, 200)).join("\n")}`).toEqual([]);
});

When(/^I go back in the browser history$/, async function (this: ScenarioWorld) {
    await this.screen.page.goBack({ waitUntil: "domcontentloaded", timeout: 30000 });
});

// Client-side routing check: a marker set on window survives a soft
// (client-side) navigation but is wiped by a full document load.
When(/^I mark the current document so a full page reload can be detected$/, async function (this: ScenarioWorld) {
    await this.screen.page.evaluate(() => { (window as unknown as Record<string, unknown>).__e2eDocumentMarker = true; });
});

Then(/^the page should( not)? have been fully reloaded since it was marked$/, async function (this: ScenarioWorld, negate: string | null) {
    const markerPresent = await this.screen.page.evaluate(() => (window as unknown as Record<string, unknown>).__e2eDocumentMarker === true);
    expect(markerPresent, negate
        ? "Expected a client-side navigation, but the document was fully reloaded (marker gone)"
        : "Expected a full page reload, but the document marker survived").toBe(!!negate);
});

// Radix/shadcn sheets and dialogs lock page scrolling while open by setting
// data-scroll-locked and overflow:hidden on <body>; other libraries set
// overflow:hidden on <html>. Either counts.
Then(/^page scrolling should( not)? be locked$/, async function (this: ScenarioWorld, negate: string | null) {
    const { page } = this.screen;
    const isLocked = () => page.evaluate(() => {
        const hidden = (el: Element) => getComputedStyle(el).overflow.includes("hidden") || getComputedStyle(el).overflowY.includes("hidden");
        return document.body.hasAttribute("data-scroll-locked") || hidden(document.body) || hidden(document.documentElement);
    });
    await waitFor(async () => (await isLocked()) === !negate, {
        expected: `page scrolling to ${negate ? "not " : ""}be locked`,
        describeActual: async () => `scroll locked: ${await isLocked()}`,
    });
});

// Text-based ordering (e.g. a "Name A-Z" sort), case- and accent-insensitive
// as a person reads it. Polls, since a re-sorted grid renders after the sort
// control reports the new option.
Then(
    /^the "([^"]*)" texts should be in (ascending|descending) alphabetical order$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, direction: "ascending" | "descending") {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
        let texts: string[] = [];
        let breakAt = -1;
        await waitFor(async () => {
            texts = (await page.locator(elementIdentifier).allTextContents()).map((t) => t.trim()).filter(Boolean);
            if (texts.length < 2) return false;
            breakAt = -1;
            for (let i = 1; i < texts.length; i++) {
                const cmp = texts[i - 1].localeCompare(texts[i], "en-GB", { sensitivity: "base", numeric: true });
                if (direction === "ascending" ? cmp > 0 : cmp < 0) { breakAt = i; break; }
            }
            return breakAt === -1;
        }, {
            timeout: 15000,
            expected: `"${elementKey}" (${elementIdentifier}) texts in ${direction} alphabetical order`,
            describeActual: async () => texts.length < 2
                ? `only ${texts.length} text(s) found`
                : `order broke at position ${breakAt}: "${texts[breakAt - 1]}" -> "${texts[breakAt]}" in ${JSON.stringify(texts)}`,
        });
    }
);

// Responsive layout check: nothing makes the page wider than the viewport
// (a horizontal scrollbar on a phone). A 1px tolerance covers sub-pixel
// rounding.
Then(/^the page should not scroll horizontally$/, async function (this: ScenarioWorld) {
    const { page } = this.screen;
    const measure = () => page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        viewport: window.innerWidth,
    }));
    let last = { scrollWidth: 0, viewport: 0 };
    await waitFor(async () => {
        last = await measure();
        return last.scrollWidth <= last.viewport + 1;
    }, {
        expected: "page content to fit the viewport width",
        describeActual: async () => `document is ${last.scrollWidth}px wide in a ${last.viewport}px viewport`,
    });
});


// A floor rather than an exact count: for "the data is still all there"
// checks after a backend upgrade (Benchmarx BEN-233, 2026-11-19), where
// content can legitimately grow but should never shrink. Polls, since a
// list re-renders after a page-size change.
Then(/^I should see at least (\d+) "([^"]*)" displayed$/, async function (this: ScenarioWorld, minimum: string, elementKey: ElementKey) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    let count = 0;
    await waitFor(async () => {
        count = await page.locator(elementIdentifier).count();
        return count >= Number(minimum);
    }, {
        expected: `at least ${minimum} "${elementKey}" (${elementIdentifier})`,
        describeActual: async () => `found ${count}`,
    });
});
