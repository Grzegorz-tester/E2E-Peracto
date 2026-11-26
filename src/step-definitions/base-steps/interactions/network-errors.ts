import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { expect } from "@playwright/test";

// The network counterpart to console-errors.ts. Built for API-upgrade
// regression (Indespension IND-729: Peracto API 65 -> 80, api-platform 3 -> 4),
// where a changed response contract tends to surface as a 4xx/5xx on a data
// call that the page then quietly renders as a blank list rather than as a
// visible error. Records every fetch/XHR response with status >= 400 whose
// host matches hostPattern, for the rest of the scenario (registered once,
// accumulates across later navigations, like the console listener).
//
// Only fetch/XHR are watched: documents are already asserted by the page
// steps, and images/fonts/third-party pixels are noise. hostPattern is a
// regex tested against the URL's host, so one step can cover a storefront's
// own origin (Next.js server actions/RSC) and its separate API host.
// ignoreUrlPattern is tested against the full URL - use it for a known,
// harmless failure (e.g. a Cloudflare 503 on a hover prefetch).
When(
    /^I start monitoring failed network responses from hosts matching "([^"]*)"(?:, ignoring URLs matching "([^"]*)")?$/,
    async function (this: ScenarioWorld, hostPattern: string, ignoreUrlPattern?: string) {
        const { screen: { page } } = this;
        const hostRegex = new RegExp(hostPattern);
        const ignoreRegex = ignoreUrlPattern ? new RegExp(ignoreUrlPattern) : null;

        this.globalVariables["__networkErrors"] = "[]";
        const record = (entry: string) => {
            const errors = JSON.parse(this.globalVariables["__networkErrors"] || "[]");
            errors.push(entry);
            this.globalVariables["__networkErrors"] = JSON.stringify(errors);
        };

        page.on("response", (response) => {
            const request = response.request();
            if (!["fetch", "xhr"].includes(request.resourceType())) return;
            const url = response.url();
            let host: string;
            try {
                host = new URL(url).host;
            } catch {
                return;
            }
            if (!hostRegex.test(host)) return;
            if (ignoreRegex && ignoreRegex.test(url)) return;
            if (response.status() >= 400) record(`${response.status()} ${request.method()} ${url}`);
        });
    },
);

Then(/^there should be no failed network responses$/, async function (this: ScenarioWorld) {
    const errors = JSON.parse(this.globalVariables["__networkErrors"] || "[]");
    expect(errors, `Failed network responses:\n${errors.join("\n")}`).toEqual([]);
});
