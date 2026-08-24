import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { getElementLocator } from "../../support-functions/web-element-helper";

// Currency-symbol-agnostic and decimal/thousands-separator-agnostic: this
// framework's projects render prices as "58,00 €" (comma decimal, symbol
// last) on some storefronts and "£58.00" (period decimal, symbol first) on
// others - whichever of "." or "," appears LAST in the numeric run is the
// real decimal separator, the other (if present) is a thousands separator.
const parsePrice = (text: string | null): number => {
    const match = text?.match(/[\d.,]*\d/);
    if (!match) return 0;
    const raw = match[0];
    const lastComma = raw.lastIndexOf(",");
    const lastDot = raw.lastIndexOf(".");
    const normalized = lastComma > lastDot
        ? raw.replace(/\./g, "").replace(",", ".")
        : raw.replace(/,/g, "");
    return parseFloat(normalized);
};

// Derives the expected total from the CURRENT unit price rather than a
// hardcoded value, so this keeps working if the product's price ever
// changes - a literal-value assertion would need updating by hand whenever
// that happens, and silently drift from meaningless (no longer possible to
// tell "feature broke" from "price changed") in the meantime. Also immune
// to exact-text-formatting gotchas (e.g. a non-breaking space before the
// currency symbol) since it parses to a number rather than string-matching
// the raw text. Reads "quantity input" / "quantity plus" / "quantity
// minus" / "basket total" from the current page's own element mappings,
// same as every other step in this framework - any project can reuse this
// step by defining those four keys in its own basket mapping file.
When(/^I (increment|decrement) the basket quantity and the total should update correctly$/, async function (this: ScenarioWorld, direction: "increment" | "decrement") {
    const { screen: { page }, globalConfig } = this;

    const quantityInput = getElementLocator(page, "quantity input", globalConfig);
    const quantityButton = getElementLocator(page, direction === "increment" ? "quantity plus" : "quantity minus", globalConfig);
    const basketTotal = getElementLocator(page, "basket total", globalConfig);

    const qtyBefore = Number(await page.inputValue(quantityInput));
    const totalBefore = parsePrice(await page.textContent(basketTotal));
    const unitPrice = totalBefore / qtyBefore;
    const qtyAfter = direction === "increment" ? qtyBefore + 1 : qtyBefore - 1;

    await page.click(quantityButton);

    await waitFor(async () => (await page.inputValue(quantityInput)) === String(qtyAfter));
    await waitFor(async () => Math.abs(parsePrice(await page.textContent(basketTotal)) - unitPrice * qtyAfter) < 0.02);
});

// For MIPA's basket, whose id loads into client state asynchronously after
// navigation/login - confirmed live, a fast automated click that mutates
// the basket (Clear Basket, Quick Order CSV upload) right after landing on
// the page can fire before that id is set, sending a PUT to
// "/baskets/undefined" that the backend 500s on. A real user never hits
// this because reading the page and moving the mouse already takes longer
// than the load - this just gives automation the same headroom.
//
// A fixed delay alone (originally 2000ms) wasn't reliably long enough -
// confirmed live, the 500 still recurred occasionally even with it. The
// real condition is "the page's own background fetches (which include
// whatever populates the basket id) have settled", which is exactly what
// "networkidle" measures, so wait for that first and treat the fixed delay
// as a floor rather than the whole story. Bounded and best-effort (a
// tracker/ad request that never goes idle shouldn't hang the step) -
// reusable by any project with a similar "id loads in after the page
// renders" race.
When(/^I wait for the basket to load$/, async function (this: ScenarioWorld) {
    const { screen: { page } } = this;
    await page.waitForLoadState("networkidle", { timeout: 8000 }).catch(() => {});
    await new Promise((resolve) => setTimeout(resolve, 1000));
});

// For a logged-in account's basket, which is server-side and persists
// across every prior test run rather than a guest's always-fresh session -
// an order-completing test needs a known, single-item basket first, not
// whatever a previous run left behind. Re-queries "remove basket line"
// fresh on each loop iteration since removing one reflows the DOM (a
// stale locator captured once up front would point at the wrong line, or
// none, after the first removal). Assumes the current page already IS the
// basket page - call "I am on the ... page" first.
When(/^I clear the basket$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;
    const removeLinkSelector = getElementLocator(page, "remove basket line", globalConfig);

    while (await page.locator(removeLinkSelector).count() > 0) {
        await page.locator(removeLinkSelector).first().click();
        await page.waitForLoadState("load");
    }
});
