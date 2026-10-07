import {Given, When} from "@cucumber/cucumber";
import {ScenarioWorld} from "../../setup/world";
import {ElementKey, PageId} from "../../../env/global";
import {
    navigateToPage,
    currentPathMatchesPageId,
} from "../../support-functions/navigation-behaviour";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {getElementLocator} from "../../support-functions/web-element-helper";

Given(/^I am on the "([^"]*)" page$/, async function (this: ScenarioWorld, pageId: PageId) {
    const {
        screen: {page},
        globalConfig,
    } = this;


    await navigateToPage(page, pageId, globalConfig);

    await waitFor(() => currentPathMatchesPageId(page, pageId, globalConfig));
});

// For any page whose client state loads in asynchronously after the initial
// render - confirmed live on MIPA's basket (an id populated after landing on
// /basket, racing a fast automated click into sending a request against it
// before it's set - "PUT /baskets/undefined", a real backend 500) and
// suspected on its Register form (shifting symptoms - empty fields, a
// button stuck disabled - consistent with the same class of "acted before
// state was ready" race). A real user never hits this: reading the page and
// moving the mouse already takes longer than the load. "networkidle" is the
// actual condition worth waiting for here (the page's own background
// fetches settling), not a guessed fixed delay - a flat 2000ms delay tried
// first still let the race through occasionally. Bounded and best-effort
// (a tracker/ad request that never goes idle shouldn't hang the step).
// Reusable by any project/page with a similar race.
When(/^I wait for the page to settle$/, async function (this: ScenarioWorld) {
    const { screen: { page } } = this;
    await page.waitForLoadState("networkidle", { timeout: 8000 }).catch(() => {});
    await new Promise((resolve) => setTimeout(resolve, 1000));
});

// CONFIRMED live (Keylite blinds configurator, 2026-09-22): clicking "Add
// to basket" fires an async POST that "I wait for the page to settle"
// doesn't reliably wait out - a DEBUG_NETWORK trace showed the confirming
// POST to a basket-related URL still hadn't landed by the time the settle
// step's own bounded networkidle+buffer window closed. Immediately
// following up with "I am on the '...' page" (an unconditional page.goto,
// see navigateToPage) then risks navigating away mid-request, losing the
// add outright rather than just running slow - a real "acted before the
// add committed" race, same class as this file's MIPA basket-id comment
// above but for the WRITE completing rather than an id being ready to
// receive one. Waits for the real signal: any non-GET response whose URL
// contains "basket", OR any Next.js server action response (request has a
// "next-action" header).
//
// CONFIRMED live (2026-09-23): the first version of this step didn't
// actually fix the race. Keylite's add is a server action POSTed to the PDP
// URL itself ("/products/blackout-blinds", body {productId, variantId, ...}),
// never a "basket" URL, so the response match never fired - and its
// networkidle fallback resolves INSTANTLY after a JS click on an
// already-loaded page (waitForLoadState returns straight away once that
// state has been reached, it doesn't wait for a fresh idle period). The step
// was effectively a flat 500ms sleep (502ms in the failing run), and the
// following page.goto still aborted the add. The networkidle fallback is
// gone for that reason; a page whose add matches neither pattern waits out
// the 15s timeout and carries on, rather than cutting the add short at 500ms.
When(/^I wait for the basket update to complete$/, async function (this: ScenarioWorld) {
    const { screen: { page } } = this;
    await page.waitForResponse((res) => {
        const req = res.request();
        return req.method() !== "GET" && (/basket/i.test(res.url()) || req.headers()["next-action"] !== undefined);
    }, { timeout: 15000 }).catch(() => null);
    await new Promise((resolve) => setTimeout(resolve, 500));
});

// A more precise counterpart to the generic settle step above, for
// waiting out a SAVE action specifically rather than an arbitrary async
// page load - e.g. before reloading right after clicking Save, per
// editing-content.feature's own confirmed race (Save completes fast with
// no toast to signal it, so a reload right after can catch the save's
// own client-side redirect still in flight). Toast behaviour for this
// varies by tenant though (see that file's comments: MIPA shows none for
// saving an existing Page/Article/Element, Andy Thornton does), so this
// can't just wait for the toast outright - that would hang for the full
// timeout on any tenant that never shows one. Races the toast appearing
// against the same networkidle-based settle instead: whichever finishes
// first wins, so a tenant with a toast gets a fast, precise signal
// (usually well under the networkidle window), and a tenant without one
// still falls back to the settle-based wait rather than the toast timeout
// eating time on top of it.
When(/^I wait for the save to complete$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;
    const toastIdentifier = getElementLocator(page, "success toast", globalConfig);

    await Promise.race([
        page.waitForSelector(toastIdentifier, { state: "visible", timeout: 8000 }).catch(() => null),
        page.waitForLoadState("networkidle", { timeout: 8000 }).catch(() => null),
    ]);
    await new Promise((resolve) => setTimeout(resolve, 500));
});

// For asserting server-persisted state survives a fresh page load, rather
// than a client-side value that would pass even if nothing was actually
// saved (e.g. Watco's account-profile VAT field).
//
// CONFIRMED (live, Andy Thornton AT-171 admin, 2026-09-10): reload() can
// itself be aborted ("net::ERR_ABORTED; maybe frame was detached?") when
// it races a still-in-flight client-side navigation from whatever action
// preceded it (e.g. a content Save's own redirect) - reproduced even
// AFTER "I wait for the page to settle" beforehand, so the settle step
// alone isn't a fully reliable fix for every timing window, just a
// reduction in how often the race is hit. A single retry after a short
// pause resolves it: by the time the retry fires, the other navigation
// has finished, so there's nothing left to race against. This only
// swallows this one specific transient navigation-level error - a genuine
// content/assertion failure after a successful reload surfaces normally,
// unaffected by this retry.
//
// Explicit 65s step timeout (CONFIRMED live, Keylite_ADMIN staging,
// 2026-09-23): this step's own budget is up to 30s + 1s + 30s, but it ran
// under cucumber's default step timeout - SCRIPT_TIMEOUT, only 20s on the
// admin envs - so one slow reload failed as "function timed out" before
// the reload's own timeout or retry ever got a chance to run.
When(/^I reload the page$/, { timeout: 65000 }, async function (this: ScenarioWorld) {
    const {screen: {page}} = this;
    try {
        await page.reload({waitUntil: "domcontentloaded", timeout: 30000});
    } catch (error) {
        if (error instanceof Error && error.message.includes("ERR_ABORTED")) {
            await new Promise((resolve) => setTimeout(resolve, 1000));
            await page.reload({waitUntil: "domcontentloaded", timeout: 30000});
        } else {
            throw error;
        }
    }
});

// Cucumber's default Playwright viewport (1280x720) is already above most
// sites' "lg" breakpoint, so mobile-only nav (e.g. KOOL's hamburger menu,
// which is "lg:hidden") never renders without explicitly narrowing the
// viewport first.
When(/^I resize the browser to a "(mobile|desktop)" viewport$/, async function (this: ScenarioWorld, size: "mobile" | "desktop") {
    const {screen: {page}} = this;
    const viewport = size === "mobile" ? {width: 390, height: 844} : {width: 1280, height: 720};
    await page.setViewportSize(viewport);
});

// Confirmed live (KOOL mobile nav drawer): clicking the dialog's own backdrop
// closes it via a mousedown handler, but the same click's mouseup/click event
// then bubbles through to whatever link sits underneath at that screen
// position once the backdrop is gone - a click-through, not a real second
// interaction. Escape avoids that hazard entirely and is the standard way to
// dismiss a HeadlessUI dialog.
When(/^I press the Escape key$/, async function (this: ScenarioWorld) {
    const {screen: {page}} = this;
    await page.keyboard.press("Escape");
});
// For a status that's only updated server-side by a background worker
// (e.g. a queued task run going "Pending" -> "Success"), so the page never
// changes on its own: reloads every few seconds until the element shows
// the expected text, instead of a single fixed wait that's either too long
// or too short.
When(/^I reload the page until the "([^"]*)" (contains|no longer contains) the (text|remembered) "([^"]*)", for up to (\d+) seconds$/, { timeout: 200000 }, async function (this: ScenarioWorld, elementKey: ElementKey, mode: string, source: string, value: string, seconds: string) {
    const {screen: {page}, globalConfig} = this;
    const expectedText = source === "remembered" ? this.globalVariables[value] : value;
    if (expectedText === undefined) {
        throw new Error(`No remembered text found for "${value}".`);
    }
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const deadline = Date.now() + Number(seconds) * 1000;
    let lastText: string | null = null;

    while (Date.now() < deadline) {
        // An input's value isn't in its textContent - read the value instead,
        // so a saved form field can be polled too (JTDove's profile page
        // keeps serving the pre-save value for a while after a successful
        // save, confirmed live 2026-10-07).
        await page.waitForSelector(elementIdentifier, {state: "attached", timeout: 5000}).catch(() => null);
        lastText = await page.$eval(elementIdentifier, (el) =>
            el instanceof HTMLInputElement || el instanceof HTMLTextAreaElement || el instanceof HTMLSelectElement
                ? el.value
                : el.textContent,
        ).catch(() => null);
        if (lastText !== null && lastText.includes(expectedText) === (mode === "contains")) {
            return;
        }
        await new Promise((resolve) => setTimeout(resolve, 5000));
        await page.reload({waitUntil: "domcontentloaded", timeout: 30000});
    }
    throw new Error(`"${elementKey}" (${elementIdentifier}) still ${mode === "contains" ? "didn't contain" : "contained"} "${expectedText}" after ${seconds}s of reloading; last text was "${lastText?.trim() ?? "(could not read text)"}".`);
});
