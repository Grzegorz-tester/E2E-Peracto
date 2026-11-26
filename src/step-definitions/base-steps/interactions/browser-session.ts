import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";

// Starts over as a brand-new anonymous visitor within the same scenario: drops
// every cookie in the context and empties local/session storage for the
// current origin. Use it to stand in for "the same customer on another
// device", e.g. a guest-basket-merge test, where signing out is not a clean
// break. CONFIRMED (Indespension staging, 2026-11-13): after Sign Out the
// guest session still carried the account's basket, so a sign-out-based merge
// test couldn't tell merging apart from simply keeping the same basket.
// Server-side state (an account's saved basket) is untouched.
When(/^I clear the browser's cookies and storage, as a new visitor$/, async function (this: ScenarioWorld) {
    const { screen: { page, context } } = this;
    await context.clearCookies();
    await page.evaluate(() => {
        try { window.localStorage.clear(); } catch { /* storage unavailable */ }
        try { window.sessionStorage.clear(); } catch { /* storage unavailable */ }
    }).catch(() => { /* page not on a scriptable origin */ });
});
