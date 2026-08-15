import { When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";

// Picks a different product from the comparison table (excluding the one
// currently being viewed) and navigates to it via its "View Product" link,
// remembering the target's own name (read from its column's image alt text)
// so a later assertion can confirm the correct PDP was reached - see "the
// ... text should equal the remembered ..." in verify-element-value.ts.
When(/^I click "View Product" for a different product in the comparison table, remembering its name as "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string) {
    const {
        screen: { page },
        globalConfig,
    } = this;

    const linksSelector = getElementLocator(page, "comparison table view product links", globalConfig);
    const links = page.locator(linksSelector);
    await expect(links.first()).toBeVisible({ timeout: 30000 });

    const currentHref = new URL(page.url()).pathname;
    const candidates: { href: string, name: string }[] = await links.evaluateAll((els, current) => els
        .map((el) => ({
            href: el.getAttribute("href") ?? "",
            name: el.closest("th")?.querySelector("img")?.getAttribute("alt") ?? "",
        }))
        .filter((p) => p.href !== current), currentHref);

    const target = candidates[0];
    if (!target) {
        throw new Error("No other product found in the comparison table.");
    }

    const link = page.locator(`a[href="${target.href}"]`).first();
    await expect(link).toBeVisible({ timeout: 15000 });
    await link.click();
    await expect(page).toHaveURL(new RegExp(`${target.href}$`), { timeout: 30000 });

    this.globalVariables[variableName] = target.name;
});
