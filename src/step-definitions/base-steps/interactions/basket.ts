import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { describeLocator, getElementLocator } from "../../support-functions/web-element-helper";
import { clickElement, withActionDiagnostics } from "../../support-functions/html-behaviour";

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

    await clickElement(page, quantityButton);

    await waitFor(async () => (await page.inputValue(quantityInput)) === String(qtyAfter), {
        expected: `basket quantity to become ${qtyAfter} after clicking "${direction === "increment" ? "quantity plus" : "quantity minus"}"`,
        describeActual: async () => `quantity input reads "${await page.inputValue(quantityInput).catch(() => "(could not read)")}"`,
    });
    await waitFor(async () => Math.abs(parsePrice(await page.textContent(basketTotal)) - unitPrice * qtyAfter) < 0.02, {
        expected: `basket total to update to ~${(unitPrice * qtyAfter).toFixed(2)} (unit price ${unitPrice.toFixed(2)} × qty ${qtyAfter})`,
        describeActual: async () => `basket total text is "${(await page.textContent(basketTotal).catch(() => null))?.trim() ?? "(could not read)"}"`,
    });
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
        const removeLink = page.locator(removeLinkSelector).first();
        await withActionDiagnostics(
            `to click "remove basket line" (${removeLinkSelector})`,
            () => describeLocator(removeLink, `"remove basket line" (${removeLinkSelector})`),
            () => removeLink.click()
        );
        await page.waitForLoadState("load");
    }
});

// For a basket holding several DIFFERENT products at once, rather than one
// product plus its own priced extras (see product-configurator.ts's "the
// basket grand total should be internally consistent", which sums a single
// line's own extras) - sums every VISIBLE "basket line total price"
// candidate (however many lines there are) and checks it against "basket
// sub total", NOT "Order total". Scoped to :visible rather than reusing
// the mapping's selector as-is: this storefront duplicates markup for
// mobile/desktop breakpoint variants elsewhere (see quote-builder.ts's
// opening comment) and a plain count/sum here would silently double-count
// a line if the same pattern applies to basket rows.
//
// CONFIRMED LIVE (staging-uk, 2026-09-09): "Order total" is NOT the sum of
// line totals - it's line totals + Delivery, all marked up by VAT (e.g. 2
// lines summing to £169.20 produced an "Order total" of £224.58, which is
// exactly (£169.20 + £17.95 delivery) × 1.2). "basket sub total" is the
// pre-delivery, ex-VAT figure that genuinely should equal the line sum.
Then(/^the basket sub total should equal the sum of all basket line totals$/, async function (this: ScenarioWorld) {
    const { screen: { page }, globalConfig } = this;

    const lineTotalSelector = `${getElementLocator(page, "basket line total price", globalConfig)}:visible`;
    const subTotalSelector = getElementLocator(page, "basket sub total", globalConfig);

    const lineTexts = await page.locator(lineTotalSelector).allTextContents();
    const linePrices = lineTexts.map(parsePrice);
    const linesSum = linePrices.reduce((sum, price) => sum + price, 0);
    const subTotal = parsePrice(await page.textContent(subTotalSelector));

    // A manual throw, not expect()'s own message argument - confirmed live
    // that Playwright's expect(value, message).toBeLessThanOrEqual(...)
    // silently drops the custom message from the reported error, leaving
    // only "Received: <number>" with no way to see what was actually
    // summed.
    const diff = Math.abs(subTotal - linesSum);
    if (diff > 0.02) {
        throw new Error(`Expected basket sub total (${subTotal}) to equal the sum of ${linePrices.length} visible basket line total(s) (${JSON.stringify(linePrices)} = ${linesSum}), off by ${diff.toFixed(2)}`);
    }
});

// For a percentage promotion (e.g. a promo code), without hardcoding the
// discounted figure - derived from the CURRENT "Y" price, for the same
// reason as the quantity step above (a literal value silently rots the
// first time the product's price changes). "equal" is the 0% case, for
// asserting a removed promotion has restored the original total. Polls,
// since a basket's totals re-render asynchronously after the promotion
// request completes. Resolves both keys through getElementLocator, so any
// project can reuse it with its own "basket total"/"basket subtotal" keys.
//
// CONFIRMED live (Keylite staging, 2026-09-23): 20SKI2025 (20% off blinds)
// takes a £91.20 subtotal to a £72.96 total - total, not subtotal, is the
// figure that moves; the discount shows as its own summary row.
Then(/^the "([^"]*)" price should (?:equal|be "(\d+(?:\.\d+)?)"% less than) the "([^"]*)" price$/, async function (this: ScenarioWorld, actualKey: string, percent: string | undefined, referenceKey: string) {
    const { screen: { page }, globalConfig } = this;
    const actualSelector = getElementLocator(page, actualKey, globalConfig);
    const referenceSelector = getElementLocator(page, referenceKey, globalConfig);
    const factor = 1 - Number(percent ?? 0) / 100;

    const read = async (selector: string) => parsePrice(await page.locator(selector).first().textContent().catch(() => null));

    await waitFor(async () => {
        const reference = await read(referenceSelector);
        return reference > 0 && Math.abs(await read(actualSelector) - reference * factor) < 0.02;
    }, {
        expected: `"${actualKey}" to equal ${percent ? `"${referenceKey}" less ${percent}%` : `"${referenceKey}"`}`,
        describeActual: async () => {
            const reference = await read(referenceSelector);
            return `"${actualKey}" is ${await read(actualSelector)}, "${referenceKey}" is ${reference} (expected ${(reference * factor).toFixed(2)})`;
        },
    });
});
