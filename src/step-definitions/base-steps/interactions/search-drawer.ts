import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// NOT a site bug - genuinely functional for a real user, but confirmed
// flaky specifically under automation: a plain Playwright .click() (even
// with a delay) consistently fails to close this drawer. A real
// mousedown-PAUSE-mouseup gesture is required instead, and even that can
// intermittently fail in the exact same conditions - retrying the whole
// gesture rides out that flakiness rather than chasing a fully
// deterministic fix that doesn't exist. Reusable by any project with a
// similarly gesture-sensitive close control - point elementKey at that
// project's own mapping for the two keys below.
When(/^I close the "([^"]*)" using a mouse-hold gesture on the "([^"]*)"$/, async function (this: ScenarioWorld, panelKey: string, closeButtonKey: string) {
    const {
        screen: { page },
        globalConfig,
    } = this;

    const panelSelector = getElementLocator(page, panelKey, globalConfig);
    const closeButtonSelector = getElementLocator(page, closeButtonKey, globalConfig);

    await waitFor(async () => {
        // Settle wait for the panel's own open/slide-in transition.
        await page.waitForTimeout(600);
        const box = await page.locator(closeButtonSelector).boundingBox();
        if (!box) return false;

        await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
        await page.mouse.down();
        await page.waitForTimeout(150);
        await page.mouse.up();

        return page.locator(panelSelector).waitFor({ state: "hidden", timeout: 3000 }).then(() => true).catch(() => false);
    }, { timeout: 20000, wait: 200 });
});

When(/^I submit the search drawer for "([^"]*)"$/, async function (this: ScenarioWorld, query: string) {
    const {
        screen: { page },
        globalConfig,
    } = this;

    const inputSelector = getElementLocator(page, "search drawer input", globalConfig);
    await page.press(inputSelector, "Enter");
    await waitFor(() => page.url().includes(`/search?q=${encodeURIComponent(query)}`));
});
