import { Given, When } from "@cucumber/cucumber";
import { Locator } from "@playwright/test";
import { ScenarioWorld } from "../../setup/world";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// A unique, clearly-ours name with a caller-chosen prefix, so a matching
// prefix-based cleanup (below) can find exactly what this suite created and
// nothing else. Confirmed need on Andy Thornton (2026-09-30): the shared test
// account holds other people's moodboards, so test data needs an unmistakable
// prefix rather than a generic "qa-<timestamp>".
When(
    /^I fill in the "([^"]*)" input field with a unique value starting with "([^"]*)", remembering it as "([^"]*)"$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, prefix: string, variableName: string) {
        const { screen: { page }, globalConfig } = this;
        const value = `${prefix} ${Date.now()}`;
        await page.fill(getElementLocator(page, elementKey, globalConfig), value);
        this.globalVariables[variableName] = value;
    }
);

// Sweeps up rows a previous, failed run left behind (a scenario that dies
// between "create" and "delete" otherwise leaves its data on a shared
// account forever). Only deletes rows whose name cell STARTS WITH the prefix,
// re-reading the list after every delete. All four are mapping keys: the row,
// the row's name cell, the row's delete control, and the confirmation button.
Given(
    /^I delete every "([^"]*)" whose "([^"]*)" starts with "([^"]*)", using the "([^"]*)" and "([^"]*)"$/,
    { timeout: 120000 },
    async function (this: ScenarioWorld, rowKey: ElementKey, nameKey: ElementKey, prefix: string, deleteKey: ElementKey, confirmKey: ElementKey) {
        const { screen: { page }, globalConfig } = this;
        const rowSelector = getElementLocator(page, rowKey, globalConfig);
        const nameSelector = getElementLocator(page, nameKey, globalConfig);
        const deleteSelector = getElementLocator(page, deleteKey, globalConfig);
        const confirmSelector = getElementLocator(page, confirmKey, globalConfig);

        const matchingRows = async () => {
            const rows = page.locator(rowSelector);
            const count = await rows.count();
            const matches: string[] = [];
            for (let i = 0; i < count; i++) {
                const name = ((await rows.nth(i).locator(nameSelector).first().textContent()) ?? "").trim();
                if (name.startsWith(prefix)) matches.push(name);
            }
            return matches;
        };

        for (let attempt = 0; attempt < 20; attempt++) {
            const [name] = await matchingRows();
            if (!name) return;
            const row = page.locator(rowSelector).filter({ has: page.locator(nameSelector, { hasText: name }) }).first();
            // Retry the delete click until its confirmation shows: straight
            // after a page load the icon can render before it's hydrated, and
            // an early click silently does nothing (confirmed live on Andy
            // Thornton's moodboards list, 2026-09-30). The confirm button can
            // also exist more than once in the DOM, so click the visible one.
            const visibleConfirm = async (): Promise<Locator | null> => {
                const candidates = page.locator(confirmSelector);
                for (let i = 0; i < await candidates.count(); i++) {
                    if (await candidates.nth(i).isVisible()) return candidates.nth(i);
                }
                return null;
            };
            let confirm: Locator | null = null;
            for (let click = 0; click < 4 && !confirm; click++) {
                await row.locator(deleteSelector).first().click();
                const deadline = Date.now() + 3000;
                while (Date.now() < deadline && !(confirm = await visibleConfirm())) {
                    await page.waitForTimeout(250);
                }
            }
            if (!confirm) throw new Error(`Clicking "${deleteKey}" never showed a visible "${confirmKey}" (${confirmSelector}) for "${name}"`);
            await confirm.click();
            await waitFor(async () => !(await matchingRows()).includes(name), {
                timeout: 20000,
                expected: `leftover "${name}" to be deleted`,
            });
        }
        throw new Error(`Still found rows starting with "${prefix}" after 20 deletions - stopping rather than looping.`);
    }
);
