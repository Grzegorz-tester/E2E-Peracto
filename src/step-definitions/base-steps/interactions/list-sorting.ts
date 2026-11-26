import { Then } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { waitFor } from "../../support-functions/wait-for-behaviour";
import { ElementKey } from "../../../env/global";

// The admin-table counterpart to wishlist.ts's "clicking the X button twice
// should reverse the Y row order", which reads each row's FIRST cell - on a
// Peracto Admin list that's the row-select checkbox, so it can't be reused.
// This reads a named cell instead (e.g. every row's Name link).
//
// Clicking a sortable header sorts ascending, then descending. The first
// click must change the order (proves the click sorted something); the
// second must give the exact reverse of the first. Only meaningful on a list
// whose cell values are distinct and not already in either order - pick a
// small, stable list.
Then(
    /^clicking the "([^"]*)" column header twice should reverse the order of the "([^"]*)" cells$/,
    async function (this: ScenarioWorld, headerKey: ElementKey, cellKey: ElementKey) {
        const { screen: { page }, globalConfig } = this;
        const headerSelector = getElementLocator(page, headerKey, globalConfig);
        const cellSelector = getElementLocator(page, cellKey, globalConfig);
        const readCells = async () => (await page.locator(cellSelector).allTextContents()).map((t) => t.trim());

        await page.locator(cellSelector).first().waitFor({ state: "visible", timeout: 15000 });
        const original = await readCells();

        await page.locator(headerSelector).first().click();
        const ascending = await waitFor(async (): Promise<string[] | undefined> => {
            const order = await readCells();
            return order.length && order.join("|") !== original.join("|") ? order : undefined;
        }, {
            expected: `the "${cellKey}" (${cellSelector}) order to change after clicking "${headerKey}" (${headerSelector})`,
            describeActual: async () => `order is still ${JSON.stringify(await readCells())}`,
        });
        if (!ascending) throw new Error("waitFor resolved without a cell order - this should be unreachable.");

        const expectedReverse = [...ascending].reverse().join("|");
        await page.locator(headerSelector).first().click();
        await waitFor(async () => (await readCells()).join("|") === expectedReverse, {
            expected: `the "${cellKey}" order to reverse after clicking "${headerKey}" a second time`,
            describeActual: async () => `order is ${JSON.stringify(await readCells())}, expected the reverse of ${JSON.stringify(ascending)}`,
        });
    },
);
