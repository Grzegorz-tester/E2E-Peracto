import { Then } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";

// Generic single-open accordion check: the first trigger starts expanded,
// opening the second collapses the first. Reusable by any project with an
// aria-expanded-driven accordion - elementKey should resolve to ALL of the
// accordion's own triggers (not scoped to just one).
Then(/^the "([^"]*)" accordion should allow only one section open at a time$/, async function (this: ScenarioWorld, elementKey: ElementKey) {
    const {
        screen: { page },
        globalConfig,
    } = this;

    const triggerSelector = getElementLocator(page, elementKey, globalConfig);
    const triggers = page.locator(triggerSelector);

    await expect(triggers.nth(0)).toHaveAttribute("aria-expanded", "true");
    await expect(triggers.nth(1)).toHaveAttribute("aria-expanded", "false");
    // A trigger far enough down a long accordion (e.g. an FAQ list with
    // many entries) can otherwise sit outside Playwright's own
    // auto-scroll margin - scrolling it into view explicitly first avoids
    // a click landing without effect.
    await triggers.nth(1).scrollIntoViewIfNeeded();
    await triggers.nth(1).click();
    await expect(triggers.nth(1)).toHaveAttribute("aria-expanded", "true");
    await expect(triggers.nth(0)).toHaveAttribute("aria-expanded", "false");
});
