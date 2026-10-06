import { Given, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";

// For a URL that pagesConfig's fixed-route-per-pageId model can't express -
// a specific catalog item reached only via UI browsing elsewhere (e.g. a
// second, differently-templated PDP), or a path with a runtime-varying
// segment (e.g. a locale prefix). Everyday page navigation should still use
// "I am on the ... page" (PageId-based, resolves through pagesConfig) - this
// is the escape hatch for the cases that don't fit that model, not a
// replacement for it.
Given(/^I navigate directly to the path "([^"]*)"$/, async function (this: ScenarioWorld, urlPath: string) {
    await navigateToPath(this, urlPath);
});

// For a URL only known at runtime (e.g. a record's detail page reached by
// clicking it), to revisit later in the same scenario - typically as a
// different user, to check that user is denied access to it.
When(/^I remember the current URL path as "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string) {
    const url = new URL(this.screen.page.url());
    this.globalVariables[variableName] = url.pathname + url.search;
});

Given(/^I navigate directly to the remembered path "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string) {
    const urlPath = this.globalVariables[variableName];
    if (urlPath === undefined) {
        throw new Error(`No remembered path found for "${variableName}" - "I remember the current URL path as ..." must run first.`);
    }
    await navigateToPath(this, urlPath);
});

async function navigateToPath(world: ScenarioWorld, urlPath: string) {
    const {
        screen: { page },
        globalConfig,
    } = world;

    const { UI_AUTOMATION_HOST: hostName = "release_branch" } = process.env;
    const hostPath = globalConfig.hostsConfig[hostName];

    // Resolved against the host rather than assigned to url.pathname: a
    // pathname assignment percent-encodes "?" and "#", so a path with a
    // query string (e.g. JTDove's "/search?q=plywood") became
    // "/search%3Fq=plywood" and 404'd.
    const url = new URL(urlPath, hostPath);

    await page.goto(url.href, { waitUntil: "domcontentloaded", timeout: 60000 });
}
