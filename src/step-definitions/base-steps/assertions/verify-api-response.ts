import { Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { isProductionRun } from "../../../env/run-environment";

// Direct HTTP checks against the site or its backend API, without a browser
// navigation: status codes (health endpoint, 401 without a token, 404 for an
// unknown route), response shape (error format fields, JSON fields a
// storefront depends on) and sitemap URLs. Built for PE-76 (PizzaExpressLive
// Peracto 79 / API Platform 4 upgrade) but generic for any project.
//
// "API" resolves against API_BASE_URL from the project's env file (e.g.
// https://staging-api.pizzaexpresslive.pub), so the feature file stays
// environment-agnostic. "site" resolves against the project's own host from
// hosts.json for the current UI_AUTOMATION_HOST.
//
// The last response is kept on the world for the assertion steps below. Uses
// the page's request context, so it carries the current session's cookies
// (or none, for a fresh guest scenario). Redirects are NOT followed, so a 301
// or 302 is reported as itself rather than as whatever it lands on.

type LastResponse = { url: string; status: number; contentType: string; lastModified?: string; body: string; setCookies: string[] };

// "Algolia" resolves against the project's public Algolia app (ALGOLIA_APP_ID
// + ALGOLIA_SEARCH_KEY in its env file - the same search-only key the
// storefront ships to every browser, so it isn't a secret). Lets a scenario
// check the search index itself, e.g. that a deleted product's record is
// gone, rather than only what the storefront's search UI happens to show.
function algoliaHeaders(): Record<string, string> {
    const appId = process.env.ALGOLIA_APP_ID;
    const key = process.env.ALGOLIA_SEARCH_KEY;
    if (!appId || !key) {
        throw new Error(`ALGOLIA_APP_ID/ALGOLIA_SEARCH_KEY are not set in this project's env file, so "Algolia path" steps can't run.`);
    }
    return { "X-Algolia-Application-Id": appId, "X-Algolia-API-Key": key };
}

function baseUrlFor(world: ScenarioWorld, target: string): string {
    if (target === "Algolia") {
        algoliaHeaders();
        return `https://${process.env.ALGOLIA_APP_ID}-dsn.algolia.net`;
    }
    if (target === "API") {
        const apiBase = process.env.API_BASE_URL;
        if (!apiBase) {
            throw new Error(`API_BASE_URL is not set in this project's env file, so "API path" steps can't resolve a host.`);
        }
        return apiBase;
    }
    const hostName = process.env.UI_AUTOMATION_HOST ?? "release_branch";
    const host = world.globalConfig.hostsConfig[hostName];
    if (!host) {
        throw new Error(`No "${hostName}" host in this project's hosts.json.`);
    }
    return host;
}

// Headers a request to this target needs on top of Accept: the Algolia app
// headers, or the bearer token from "I authenticate against the API as ..."
// once a scenario has one (never printed - only ever sent).
function headersFor(world: ScenarioWorld, target: string): Record<string, string> {
    if (target === "Algolia") return algoliaHeaders();
    const token = world.globalVariables["__apiToken"];
    return target === "API" && token ? { Authorization: `Bearer ${token}` } : {};
}

// Replaces {{name}} with a value remembered earlier in the scenario (e.g. an
// order reference read off the thank-you page, or a product id from a create
// response), and {{env.NAME}} with a non-secret env var (e.g. the project's
// ALGOLIA_INDEX), so a feature stays environment-agnostic. Credentials and
// tokens can't be pulled in this way, since a path ends up in failure messages.
export function interpolate(world: ScenarioWorld, text: string): string {
    return text.replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_, name: string) => {
        if (name.startsWith("env.")) {
            const envName = name.slice(4);
            if (/PASSWORD|TOKEN|SECRET|_KEY$/i.test(envName) && envName !== "ALGOLIA_SEARCH_KEY") {
                throw new Error(`{{env.${envName}}} looks like a secret and can't be interpolated.`);
            }
            const value = process.env[envName];
            if (value === undefined) throw new Error(`{{env.${envName}}} is not set in this project's env file.`);
            return value;
        }
        const value = world.globalVariables[name];
        if (value === undefined) throw new Error(`No remembered value for "{{${name}}}".`);
        return value;
    });
}

// Writes through the API are staging-only: production's admin is read-only
// (CLAUDE.md). Reads, and POSTing credentials to log in, stay allowed.
function refuseWriteOnProduction(method: string, target: string) {
    if (isProductionRun() && target === "API" && method !== "GET") {
        throw new Error(`Refusing ${method} to the API on a production run - API writes are staging-only.`);
    }
}

async function request(
    world: ScenarioWorld, url: string, method: string, data?: unknown, target = "",
): Promise<LastResponse> {
    const { screen: { page } } = world;
    const response = await page.request.fetch(url, {
        method,
        timeout: 30000,
        maxRedirects: 0,
        headers: {
            Accept: "application/ld+json, application/json;q=0.9, */*;q=0.8",
            ...(data !== undefined ? { "Content-Type": "application/json" } : {}),
            ...headersFor(world, target),
        },
        ...(data !== undefined ? { data } : {}),
    });
    return {
        url,
        status: response.status(),
        contentType: response.headers()["content-type"] ?? "",
        lastModified: response.headers()["last-modified"],
        body: await response.text(),
        // Only the cookie name and attributes are kept, never the value, so
        // a token can't leak into an assertion message or the report.
        setCookies: response.headersArray()
            .filter((h) => h.name.toLowerCase() === "set-cookie")
            .map((h) => h.value.replace(/^([^=]+)=[^;]*/, "$1=<value>")),
    };
}

function store(world: ScenarioWorld, res: LastResponse) {
    world.globalVariables["__lastResponse"] = JSON.stringify(res);
}

function lastResponse(world: ScenarioWorld): LastResponse {
    const raw = world.globalVariables["__lastResponse"];
    if (!raw) {
        throw new Error(`No response captured - a "I (GET|POST) the API/site path ..." step must run first.`);
    }
    return JSON.parse(raw);
}

function resolveJsonPath(body: string, fieldPath: string, url: string): unknown {
    let data: unknown;
    try {
        data = JSON.parse(body);
    } catch {
        throw new Error(`Response from ${url} is not JSON: ${body.slice(0, 200)}`);
    }
    const segments = fieldPath.replace(/\[(\d+)\]/g, ".$1").split(".").filter(Boolean);
    let value: unknown = data;
    for (const segment of segments) {
        if (value === null || value === undefined) break;
        value = (value as Record<string, unknown>)[segment];
    }
    return value;
}

When(
    /^I (GET|POST|DELETE) the (API|site|Algolia) path "([^"]*)"$/,
    async function (this: ScenarioWorld, method: string, target: string, path: string) {
        if (method === "DELETE") refuseWriteOnProduction(method, target);
        const url = new URL(interpolate(this, path), baseUrlFor(this, target)).toString();
        store(this, await request(this, url, method, undefined, target));
    }
);

// A JSON body in a doc string, with {{name}}/{{env.NAME}} interpolated, e.g.
// creating a throwaway "Velstar Test" product through the admin API. API
// writes are refused on production.
When(
    /^I (POST|PUT) the (API|Algolia) path "([^"]*)" with the JSON body:$/,
    async function (this: ScenarioWorld, method: string, target: string, path: string, body: string) {
        refuseWriteOnProduction(method, target);
        const url = new URL(interpolate(this, path), baseUrlFor(this, target)).toString();
        let data: unknown;
        try {
            data = JSON.parse(interpolate(this, body));
        } catch (err) {
            throw new Error(`The JSON body for ${method} ${path} isn't valid JSON: ${(err as Error).message}`);
        }
        store(this, await request(this, url, method, data, target));
    }
);

// Re-requests until the status matches, for something that settles
// asynchronously (a search index catching up with a create or delete, a
// background task finishing). Polls every 5s; the last response is kept for
// the assertion steps either way, and the failure names the last status.
When(
    /^I GET the (API|site|Algolia) path "([^"]*)" until the response (?:status is (\d+)|body contains "([^"]*)")(?: within (\d+) seconds)?$/,
    // Cucumber's default step timeout would cut the poll short; the poll's own
    // deadline (plus one 30s request) bounds it instead, up to 15 minutes.
    // The "body contains" form waits for an admin change to reach a cached
    // storefront page (Next.js revalidation), with {{name}} interpolated.
    { timeout: 15 * 60 * 1000 },
    async function (this: ScenarioWorld, target: string, path: string, expected: string | null, text: string | null, seconds?: string | null) {
        const url = new URL(interpolate(this, path), baseUrlFor(this, target)).toString();
        // Cucumber passes null (not undefined) for an optional group that didn't match.
        const wanted = text == null ? undefined : interpolate(this, text);
        const done = (r: LastResponse) => (wanted === undefined ? r.status === Number(expected) : r.body.includes(wanted));
        const deadline = Date.now() + Number(seconds ?? 60) * 1000;
        let res: LastResponse;
        for (;;) {
            res = await request(this, url, "GET", undefined, target);
            if (done(res) || Date.now() > deadline) break;
            await new Promise((r) => setTimeout(r, 5000));
        }
        store(this, res);
        if (wanted === undefined) {
            expect(res.status, `${url} was still ${res.status} after ${seconds ?? 60}s, expected ${expected}`).toBe(Number(expected));
        } else {
            expect(done(res), `${url} (status ${res.status}) still didn't contain "${wanted}" after ${seconds ?? 60}s`).toBe(true);
        }
    }
);

// Logs in through the API and keeps the bearer token for the rest of the
// scenario, so later "API path" requests are authenticated as that user
// (e.g. reading the admin's view of an order the storefront just placed).
// The auth path defaults to Peracto's /auth (API_AUTH_PATH overrides). The
// token is only ever sent, never stored in the report or printed.
When(
    /^I authenticate against the API as the "([^"]*)" user$/,
    async function (this: ScenarioWorld, userType: string) {
        const user = this.globalConfig.usersConfig[userType.trim().toLowerCase()];
        if (!user?.email || !user?.password) {
            throw new Error(`Missing credentials for user type "${userType}". Check users.json and the env vars.`);
        }
        const url = new URL(process.env.API_AUTH_PATH ?? "/auth", baseUrlFor(this, "API")).toString();
        const res = await request(this, url, "POST", { email: user.email, password: user.password }, "API");
        let token: unknown;
        try {
            token = JSON.parse(res.body).token;
        } catch {
            token = undefined;
        }
        if (res.status !== 200 || typeof token !== "string") {
            throw new Error(`API login as "${userType}" failed: ${url} -> ${res.status}`);
        }
        this.globalVariables["__apiToken"] = token;
    }
);

// A per-scenario unique value (prefix + timestamp), e.g. a throwaway
// product's SKU and slug, so reruns never collide with an earlier leftover.
When(
    /^I remember a unique value starting with "([^"]*)" as "([^"]*)"$/,
    async function (this: ScenarioWorld, prefix: string, variableName: string) {
        this.globalVariables[variableName] = `${prefix}${Date.now()}`;
    }
);

// Registers an API DELETE to run after the scenario whatever its outcome,
// so a test fixture created mid-scenario (a throwaway product) is cleaned up
// even when a later step fails. A scenario that deletes it itself just gets
// a harmless 404 here. Runs with the scenario's own API token.
When(
    /^I will DELETE the API path "([^"]*)" after the scenario$/,
    async function (this: ScenarioWorld, path: string) {
        refuseWriteOnProduction("DELETE", "API");
        const url = new URL(interpolate(this, path), baseUrlFor(this, "API")).toString();
        const pending = JSON.parse(this.globalVariables["__apiCleanup"] || "[]");
        pending.push(url);
        this.globalVariables["__apiCleanup"] = JSON.stringify(pending);
    }
);

export async function runApiCleanup(world: ScenarioWorld): Promise<void> {
    const pending: string[] = JSON.parse(world.globalVariables?.["__apiCleanup"] || "[]");
    // Newest first: something created later (a menu item) usually points at
    // something created earlier (its content page), so it goes first.
    for (const url of [...pending].reverse()) {
        try {
            const res = await request(world, url, "DELETE", undefined, "API");
            if (![200, 202, 204, 404].includes(res.status)) {
                console.error(`API cleanup DELETE ${url} -> ${res.status}; delete it by hand.`);
            }
        } catch (err) {
            console.error(`API cleanup DELETE ${url} failed: ${(err as Error).message}; delete it by hand.`);
        }
    }
}

// Logs in against the API directly (e.g. Peracto's POST /auth) with a user
// type's real credentials from users.json + env vars. The password is only
// ever sent, never stored or printed. Any cookies the response sets go into
// this scenario's browser context, exactly as they would for a real client,
// so a following request sends them back.
When(
    /^I POST the API path "([^"]*)" with the "([^"]*)" user's credentials$/,
    async function (this: ScenarioWorld, path: string, userType: string) {
        const user = this.globalConfig.usersConfig[userType.trim().toLowerCase()];
        if (!user?.email || !user?.password) {
            throw new Error(`Missing credentials for user type "${userType}". Check users.json and the env vars.`);
        }
        const url = new URL(path, baseUrlFor(this, "API")).toString();
        store(this, await request(this, url, "POST", { email: user.email, password: user.password }));
    }
);

When(
    /^I POST the API path "([^"]*)" with the remembered "([^"]*)" as the JSON field "([^"]*)"$/,
    async function (this: ScenarioWorld, path: string, variableName: string, field: string) {
        const value = this.globalVariables[variableName];
        if (value === undefined) {
            throw new Error(`No remembered value for "${variableName}".`);
        }
        const url = new URL(path, baseUrlFor(this, "API")).toString();
        store(this, await request(this, url, "POST", { [field]: value }));
    }
);

When(
    /^I remember the response JSON at "([^"]*)" as "([^"]*)"$/,
    async function (this: ScenarioWorld, fieldPath: string, variableName: string) {
        const res = lastResponse(this);
        const value = resolveJsonPath(res.body, fieldPath, res.url);
        if (value === undefined || value === null || value === "") {
            throw new Error(`Nothing to remember at "${fieldPath}" in ${res.url}`);
        }
        this.globalVariables[variableName] = String(value);
    }
);

// Empties this scenario's cookie jar without closing the page, so a
// following API request carries only what the step itself sends (e.g. a
// refresh token in the body, with no refresh_token cookie alongside it).
When(/^I clear the browser's cookies$/, async function (this: ScenarioWorld) {
    await this.screen.context.clearCookies();
});

Then(/^the response status should be (\d+)$/, async function (this: ScenarioWorld, expected: string) {
    const res = lastResponse(this);
    expect(res.status, `${res.url} -> ${res.status}: ${res.body.slice(0, 300)}`).toBe(Number(expected));
});

Then(/^the response content-type should contain "([^"]*)"$/, async function (this: ScenarioWorld, expected: string) {
    const res = lastResponse(this);
    expect(res.contentType, `${res.url} content-type`).toContain(expected);
});

// Freshness of a file a scheduled backend task regenerates (e.g. a sitemap
// written to S3 nightly): a task that silently stopped running - no schedule,
// a Lambda runtime that no longer boots - still leaves the old file served
// with a 200, so only its age gives it away. Built for HIB-179 (PHP 8.5 /
// Bref v3 moves every scheduled task to a new Lambda runtime).
Then(
    /^the response should have been last modified within the last (\d+) days?$/,
    async function (this: ScenarioWorld, days: string) {
        const res = lastResponse(this);
        if (!res.lastModified) {
            throw new Error(`${res.url} sent no Last-Modified header, so its age can't be checked.`);
        }
        const ageDays = (Date.now() - new Date(res.lastModified).getTime()) / 86_400_000;
        expect(
            ageDays,
            `${res.url} was last modified ${res.lastModified} (${ageDays.toFixed(1)} days ago), expected within ${days} days`,
        ).toBeLessThanOrEqual(Number(days));
    }
);

Then(/^the response body should( not)? contain "([^"]*)"$/, async function (this: ScenarioWorld, negate: string | null, text: string) {
    const res = lastResponse(this);
    const expected = interpolate(this, text);
    if (negate) {
        expect(res.body, `${res.url} body`).not.toContain(expected);
    } else {
        expect(res.body, `${res.url} body`).toContain(expected);
    }
});

// Present = not missing, not null, not "" and not an empty array. Numbers
// (including 0) and booleans count as present.
Then(/^the response JSON at "([^"]*)" should be present$/, async function (this: ScenarioWorld, fieldPath: string) {
    const res = lastResponse(this);
    const value = resolveJsonPath(res.body, fieldPath, res.url);
    const isPresent = value !== undefined && value !== null && value !== "" &&
        !(Array.isArray(value) && value.length === 0);
    expect(isPresent, `Expected "${fieldPath}" in ${res.url}, got: ${JSON.stringify(value)}`).toBe(true);
});

Then(
    /^the response JSON at "([^"]*)" should( not)? equal the remembered "([^"]*)"$/,
    async function (this: ScenarioWorld, fieldPath: string, negate: string | null, variableName: string) {
        const res = lastResponse(this);
        const remembered = this.globalVariables[variableName];
        if (remembered === undefined) {
            throw new Error(`No remembered value for "${variableName}".`);
        }
        const same = String(resolveJsonPath(res.body, fieldPath, res.url)) === remembered;
        // Values are tokens, so only the outcome is reported, never the values.
        expect(same, `"${fieldPath}" in ${res.url} was ${same ? "the same as" : "different from"} "${variableName}"`).toBe(!negate);
    }
);

// e.g. the "refresh_token" cookie with "HttpOnly, Secure, SameSite=None".
// Each listed attribute must be present (case-insensitive); a name=value
// attribute must match its value too.
Then(
    /^the response should set the "([^"]*)" cookie with "([^"]*)"$/,
    async function (this: ScenarioWorld, cookieName: string, attributeList: string) {
        const res = lastResponse(this);
        const cookie = res.setCookies.find((c) => c.split("=")[0].trim() === cookieName);
        expect(cookie, `No "${cookieName}" cookie set by ${res.url}. Set: ${res.setCookies.map((c) => c.split("=")[0]).join(", ") || "none"}`).toBeDefined();
        const attributes = cookie!.split(";").slice(1).map((a) => a.trim().toLowerCase());
        const missing = attributeList.split(",").map((a) => a.trim()).filter(Boolean)
            .filter((wanted) => {
                const [key, value] = wanted.toLowerCase().split("=").map((x) => x.trim());
                return !attributes.some((a) => {
                    const [k, v] = a.split("=").map((x) => x.trim());
                    return k === key && (value === undefined || v === value);
                });
            });
        expect(missing, `"${cookieName}" cookie from ${res.url} is missing attributes. Got: ${cookie}`).toEqual([]);
    }
);

Then(/^the response JSON at "([^"]*)" should( not)? equal "([^"]*)"$/, async function (this: ScenarioWorld, fieldPath: string, negate: string | null, expected: string) {
    const res = lastResponse(this);
    const value = resolveJsonPath(res.body, fieldPath, res.url);
    if (negate) {
        expect(String(value), `"${fieldPath}" in ${res.url}`).not.toBe(expected);
    } else {
        expect(String(value), `"${fieldPath}" in ${res.url}`).toBe(expected);
    }
});

// For an array where each entry must carry a field the frontend reads (e.g.
// every hydra:member has a slug), so a field dropped by a serializer change
// is caught across the whole page, not just on item [0].
Then(
    /^every entry in the response JSON at "([^"]*)" should have a "([^"]*)" field$/,
    async function (this: ScenarioWorld, arrayPath: string, key: string) {
        const res = lastResponse(this);
        const value = resolveJsonPath(res.body, arrayPath, res.url);
        expect(Array.isArray(value) && value.length > 0, `Expected a non-empty array at "${arrayPath}" in ${res.url}`).toBe(true);
        const missing = (value as Record<string, unknown>[])
            .map((entry, i) => (entry && entry[key] !== undefined && entry[key] !== null ? null : i))
            .filter((i) => i !== null);
        expect(missing, `Entries at "${arrayPath}" missing "${key}" (indexes)`).toEqual([]);
    }
);

// Order-independent membership check, e.g. an order's lines include SKU
// 310239 sent for "delivery", whatever position the API returns it in.
// entryField is a path within each entry ("item.sku").
Then(
    /^the response JSON at "([^"]*)" should contain an entry whose "([^"]*)" is "([^"]*)"(?: and whose "([^"]*)" is "([^"]*)")?$/,
    async function (this: ScenarioWorld, arrayPath: string, field: string, value: string, field2?: string, value2?: string) {
        const res = lastResponse(this);
        const entries = resolveJsonPath(res.body, arrayPath, res.url);
        expect(Array.isArray(entries), `Expected an array at "${arrayPath}" in ${res.url}`).toBe(true);
        const matches = (entry: unknown, path: string, expected: string) =>
            String(resolveJsonPath(JSON.stringify(entry), path, res.url)) === expected;
        const found = (entries as unknown[]).some((entry) =>
            matches(entry, field, value) && (field2 == null || matches(entry, field2, value2 ?? "")));
        const seen = (entries as unknown[]).map((entry) =>
            [field, field2].filter(Boolean).map((f) => String(resolveJsonPath(JSON.stringify(entry), f!, res.url))).join("/"));
        expect(found, `No entry at "${arrayPath}" in ${res.url} with ${field}=${value}${field2 ? ` and ${field2}=${value2}` : ""}. Saw: ${seen.join(", ")}`).toBe(true);
    }
);

// Samples URLs evenly across a sitemap (first, then every Nth) rather than
// just the first few, so a broken URL pattern for one content type shows up.
// Each URL is requested with redirects followed, since a sitemap pointing at
// the apex domain that 301s to www is fine as long as it lands on a 200.
Then(
    /^(\d+) URLs sampled from the sitemap response should each return status 200$/,
    async function (this: ScenarioWorld, sampleSize: string) {
        const res = lastResponse(this);
        const locs = [...res.body.matchAll(/<loc>\s*([^<\s]+)\s*<\/loc>/g)].map((m) => m[1]);
        expect(locs.length, `No <loc> entries in ${res.url}`).toBeGreaterThan(0);
        const n = Math.min(Number(sampleSize), locs.length);
        const step = locs.length / n;
        const sample = Array.from({ length: n }, (_, i) => locs[Math.floor(i * step)]);

        const { screen: { page } } = this;
        const failures: string[] = [];
        for (const url of sample) {
            const response = await page.request.get(url, { timeout: 30000 });
            if (response.status() !== 200) failures.push(`${response.status()} ${url}`);
        }
        expect(failures, `${failures.length}/${n} sampled URLs from ${res.url} did not return 200`).toEqual([]);
    }
);
