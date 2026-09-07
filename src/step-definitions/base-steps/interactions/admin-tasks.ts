import { When } from "@cucumber/cucumber";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { clickElementAtIndex } from "../../support-functions/html-behaviour";
import { ScenarioWorld } from "../../setup/world";
import { waitFor } from "../../support-functions/wait-for-behaviour";

// Peracto Admin's Tasks tab renders one row per backend job, each with its
// own "play" button that triggers a real run. Confirmed live (MIPA_ADMIN
// staging, 2026-08-30): clicking it raises a distinct "The {task_slug}
// task will begin shortly." success toast per row, with the slug taken
// from that same row's own link href (e.g. /tasks/hello_world ->
// "hello_world") - so this checks each row against its OWN slug rather
// than a fixed list of expected task names, meaning a task added or
// removed on the backend later doesn't require any feature file to be
// updated. Both the button and row-link mapping keys are parameters
// (rather than hardcoded here) so this is reusable by any Peracto Admin
// tenant's Tasks tab, not just MIPA's - the row-per-job shape is shared
// boilerplate per CLAUDE.md, even though triggering one is a real
// backend-mutating action and so isn't safe to run against a tenant with
// a production admin (see this repo's staging-vs-production rules).
//
// Closes each toast before moving to the next row so a still-visible
// earlier toast can't be mistaken for the next row's own confirmation -
// this framework's own "the X should contain the text Y" assertion reads
// the FIRST matching element's text, which would otherwise risk picking
// up a stale toast rather than the new one.
// Explicit generous step timeout rather than relying on each project's own
// SCRIPT_TIMEOUT default - confirmed live (Insinkerator staging,
// 2026-08-31): this step loops over every row within a SINGLE cucumber
// step, so its total duration scales with how many tasks a tenant has
// (12 rows x a toast wait + dismiss each comfortably exceeds the 20000ms
// default, even though every individual Playwright action inside succeeds
// fine) - MIPA's own bumped SCRIPT_TIMEOUT (for an unrelated slow-login
// reason) happened to mask this for that one tenant, but it isn't a
// substitute for this step declaring what IT actually needs. Bumped again
// to 120000ms after Carbon Admin (confirmed live, 2026-08-31, 15 tasks)
// still timed out at 60000ms once its own missing "success toast" mapping
// key was fixed and every row's toast wait/dismiss actually ran for real -
// sized with headroom for tenants with more than 15 tasks, not just
// exactly enough for the largest one seen so far.
When(
  /^I click on the "([^"]*)" for every "([^"]*)" row, confirming the "([^"]*)" appears each time$/,
  { timeout: 120000 },
  async function (
    this: ScenarioWorld,
    buttonKey: ElementKey,
    rowLinkKey: ElementKey,
    toastKey: ElementKey
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const linkIdentifier = getElementLocator(page, rowLinkKey, globalConfig);
    const buttonIdentifier = getElementLocator(page, buttonKey, globalConfig);
    const toastIdentifier = getElementLocator(page, toastKey, globalConfig);

    // The list is client-fetched, not present in the initial HTML - without
    // this wait, count() below can run before a single row has rendered yet
    // and report zero rows even though the page genuinely has some.
    await page.waitForSelector(linkIdentifier, { state: "attached", timeout: 15000 });

    const links = page.locator(linkIdentifier);
    const rowCount = await links.count();
    if (rowCount === 0) {
      throw new Error(`No rows found - no elements matched "${rowLinkKey}" (${linkIdentifier}).`);
    }

    for (let i = 0; i < rowCount; i++) {
      const href = await links.nth(i).getAttribute("href");
      const slug = href?.split("/").filter(Boolean).pop();
      if (!slug) {
        throw new Error(`Could not determine a task slug from row ${i + 1}'s link (href was "${href}").`);
      }

      await clickElementAtIndex(page, buttonIdentifier, i, { force: true });

      const expectedText = `The ${slug} task will begin shortly.`;
      await waitFor(
        async () => {
          const text = await page.textContent(toastIdentifier).catch(() => null);
          return text?.includes(expectedText) ?? false;
        },
        {
          expected: `"${toastKey}" to contain "${expectedText}" after triggering row ${i + 1} ("${slug}")`,
          describeActual: async () =>
            `text was "${(await page.textContent(toastIdentifier).catch(() => null))?.trim() ?? "(no toast found)"}"`,
        }
      );

      await page
        .evaluate(() => {
          document.querySelectorAll(".Toastify__close-button").forEach((button) => (button as HTMLElement).click());
        })
        .catch(() => {});
      await page.waitForTimeout(400);
    }
  }
);
