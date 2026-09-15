import { When } from "@cucumber/cucumber";
import { Page } from "playwright";
import { ElementKey, GlobalConfig } from "../../../env/global";
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
// exactly enough for the largest one seen so far. Bumped again, to
// 300000ms, once every row started being checked independently (below)
// rather than stopping at the first failure - a row that fails now still
// burns its own full ~15s "success toast" poll before moving on (there's
// no success toast to find, so it always runs to the poll's own timeout).
// CONFIRMED (live, MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08): before the
// readToast() timeout fix below existed, a failing row's poll wasn't
// costing ~15s at all - it was costing ~40s (a bare page.textContent()
// blocking ~30s per poll attempt once the toast auto-dismissed between
// polls), so 8 failing tasks alone pushed a single attempt past even
// 300000ms. With that fixed, actual worst-case is back down near the
// "~15s per failing row" math this comment describes - 300000ms is kept
// as headroom for a tenant with more tasks than MIPA, not because that
// much time is expected to actually be used.
const triggerEveryTaskRow = async (
  page: Page,
  globalConfig: GlobalConfig,
  buttonKey: ElementKey,
  rowLinkKey: ElementKey,
  toastKey: ElementKey,
  excludeSlugs: string[]
) => {
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

  // Every row is checked independently - a failing task must not stop the
  // rest from being exercised (each one is its own thing to verify, not a
  // chain where the first failure is "good enough" to report), and every
  // task is expected to genuinely succeed regardless of its Active/
  // Inactive status (that flag only controls whether it ALSO runs on a
  // schedule - CONFIRMED live, MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08: it's
  // not a "this one's allowed to fail" marker, so an Inactive task 500ing
  // on manual trigger is a real bug, not expected behaviour). Failures
  // are collected and reported together at the end instead of throwing on
  // the first one, so a single bad task doesn't hide every other failure
  // behind it.
  const failures: string[] = [];

  for (let i = 0; i < rowCount; i++) {
    const href = await links.nth(i).getAttribute("href");
    const slug = href?.split("/").filter(Boolean).pop();
    if (!slug) {
      throw new Error(`Could not determine a task slug from row ${i + 1}'s link (href was "${href}").`);
    }
    if (excludeSlugs.includes(slug)) {
      continue;
    }

    await clickElementAtIndex(page, buttonIdentifier, i, { force: true });

    const expectedText = `The ${slug} task will begin shortly.`;
    // CONFIRMED (live, MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08): a bare
    // page.textContent(selector) auto-waits (Playwright's own default
    // actionability timeout, ~30s) for the selector to become attached
    // when it currently ISN'T - and Toastify auto-dismisses each toast
    // within a few seconds, so once a toast has already vanished between
    // polls, a bare call here blocks for ~30s rather than failing fast.
    // That turned "poll every 2s for up to 15s" into ~40s PER row once
    // every row started being checked independently instead of stopping
    // at the first failure (the bug was always there, just invisible
    // while only one failing row was ever reached). An explicit short
    // per-call timeout keeps each poll fast regardless of whether the
    // toast happens to be up at that instant.
    const readToast = () => page.textContent(toastIdentifier, { timeout: 500 }).catch(() => null);
    try {
      await waitFor(
        async () => {
          const text = await readToast();
          return text?.includes(expectedText) ?? false;
        },
        {
          expected: `"${toastKey}" to contain "${expectedText}" after triggering row ${i + 1} ("${slug}")`,
          describeActual: async () => `text was "${(await readToast())?.trim() ?? "(no toast found)"}"`,
        }
      );
    } catch (error) {
      failures.push(error instanceof Error ? error.message : String(error));
    }

    await page
      .evaluate(() => {
        document.querySelectorAll(".Toastify__close-button").forEach((button) => (button as HTMLElement).click());
      })
      .catch(() => {});
    await page.waitForTimeout(400);
  }

  if (failures.length > 0) {
    throw new Error(`${failures.length} task(s) failed to trigger successfully:\n\n${failures.join("\n\n")}`);
  }
};

When(
  /^I click on the "([^"]*)" for every "([^"]*)" row, confirming the "([^"]*)" appears each time$/,
  { timeout: 300000 },
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

    await triggerEveryTaskRow(page, globalConfig, buttonKey, rowLinkKey, toastKey, []);
  }
);

// An "excluding" variant of the above - for a task that isn't worth
// exercising at all (e.g. leftover dev/test scaffolding on the backend
// rather than a real business task), rather than one this suite expects
// to genuinely succeed. Slugs are comma-separated and matched against
// each row's own href-derived slug, same source the base step already
// uses - so excluding "hello_world" here means the literal task at
// /tasks/hello_world, regardless of its position in the list.
When(
  /^I click on the "([^"]*)" for every "([^"]*)" row, confirming the "([^"]*)" appears each time, excluding "([^"]*)"$/,
  { timeout: 300000 },
  async function (
    this: ScenarioWorld,
    buttonKey: ElementKey,
    rowLinkKey: ElementKey,
    toastKey: ElementKey,
    excludeSlugsCsv: string
  ) {
    const {
      screen: { page },
      globalConfig,
    } = this;

    const excludeSlugs = excludeSlugsCsv.split(",").map((s) => s.trim()).filter(Boolean);
    await triggerEveryTaskRow(page, globalConfig, buttonKey, rowLinkKey, toastKey, excludeSlugs);
  }
);
