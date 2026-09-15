import { DataTable, Given, When } from "@cucumber/cucumber";
import { Page } from "playwright";
import { ElementKey, GlobalConfig } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { clickElement, enterValue } from "../../support-functions/html-behaviour";
import { ScenarioWorld } from "../../setup/world";

// Second, independent layer of protection beyond the @mutates-admin-data
// tag exclusion wired into src/index.ts's productionExclusion - if a
// scenario's tag were ever missing, or a profile's tag filter got
// misconfigured, this makes the scenario refuse to run the instant it
// starts, rather than silently adding/editing/deleting real address data
// on a tenant's production admin (see CLAUDE.md's "Staging vs production
// rules": a production admin must stay read-only). Deliberately does not
// depend on the tag exclusion in any way - it re-derives the same
// UI_AUTOMATION_HOST check independently, the same source
// navigation-behaviour.ts's own navigateToPage reads.
Given(/^I require a staging admin for this scenario$/, async function () {
  if (process.env.UI_AUTOMATION_HOST === "production") {
    throw new Error(
      "Refusing to run: this scenario mutates admin data (adds/edits/deletes a user's address) and UI_AUTOMATION_HOST is \"production\". " +
      "This should already be excluded via the @mutates-admin-data tag in src/index.ts - seeing this error means that exclusion didn't apply."
    );
  }
});

// Peracto Admin renders each saved address as a plain read-only block
// (an "address entry", e.g. "<address>...</address>") with its own Edit
// button as a following SIBLING, not a child - confirmed live (Carbon
// Admin staging, 2026-08-31). A user can have several unrelated real
// addresses already, so this finds the one containing whatever this
// scenario itself created (identified by its own remembered marker
// value) rather than assuming "the first" or "the last" address is ours.
When(
  /^I click the "Edit" button for the address containing the remembered "([^"]*)"$/,
  async function (this: ScenarioWorld, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const remembered = this.globalVariables[variableName];
    if (remembered === undefined) {
      throw new Error(`No remembered text found for "${variableName}" - a "... remembering it as ..." step must run first.`);
    }

    const addressIdentifier = getElementLocator(page, "address entry", globalConfig);
    const addressEntry = page.locator(addressIdentifier).filter({ hasText: remembered });
    await addressEntry.first().waitFor({ state: "visible", timeout: 15000 });
    await addressEntry.first().locator("xpath=following-sibling::button[1]").click();
  }
);

// Peracto Admin's "Address Type" (and "Title"/"Country") fields are the
// classic react-select widget (see form.ts's "... react-select" step) -
// duplicated in miniature here rather than imported, since that step is
// registered directly with Cucumber's When() and isn't callable as a
// plain function.
// CONFIRMED (live, Keylite_ADMIN_RELEASE, 2026-09-14): Country options
// aren't always the short form the shared feature file hardcodes -
// Keylite's list renders "United Kingdom Of Great Britain & Northern
// Ireland" rather than "United Kingdom", so the exact match below never
// resolves and the whole step hangs until the 20s function timeout.
// Exact match stays the default (needed so "Mr" doesn't accidentally
// match "Mrs" for Title) - only falls back to a prefix match when no
// exact option exists, which for Type/Title never triggers since those
// options are always exact elsewhere.
const selectAddressTypeReactSelect = async (page: Page, globalConfig: GlobalConfig, elementKey: ElementKey, option: string) => {
  const control = page.locator(getElementLocator(page, elementKey, globalConfig));
  await control.click();
  const menu = page.locator(".list__menu:visible").last();
  await menu.locator(".list__option").first().waitFor({ state: "visible", timeout: 10000 });
  const exactMatch = menu.getByText(option, { exact: true });
  if (await exactMatch.count() > 0) {
    await exactMatch.click();
  } else {
    await menu.locator(".list__option", { hasText: option }).first().click();
  }
};

const fillNewAddressForm = async (page: Page, globalConfig: GlobalConfig, addressType: string, fields: { [key: string]: string }, lastName: string) => {
  await clickElement(page, getElementLocator(page, "Add New Address", globalConfig));
  await selectAddressTypeReactSelect(page, globalConfig, "Address Type", addressType);
  await selectAddressTypeReactSelect(page, globalConfig, "Address Title", fields["title"]);
  await enterValue(page, getElementLocator(page, "Address First Name", globalConfig), fields["first name"]);
  await enterValue(page, getElementLocator(page, "Address Last Name", globalConfig), lastName);
  await enterValue(page, getElementLocator(page, "Address Line 1", globalConfig), fields["line 1"]);
  await enterValue(page, getElementLocator(page, "Address City", globalConfig), fields["city"]);
  await enterValue(page, getElementLocator(page, "Address Postcode", globalConfig), fields["postcode"]);
  await selectAddressTypeReactSelect(page, globalConfig, "Address Country", fields["country"]);
  await clickElement(page, getElementLocator(page, "Save Address", globalConfig));
};

const addressIsPersisted = async (page: Page, globalConfig: GlobalConfig, marker: string) => {
  await page.reload({ waitUntil: "domcontentloaded" });
  const addressIdentifier = getElementLocator(page, "address entry", globalConfig);
  await page.locator(addressIdentifier).first().waitFor({ state: "attached", timeout: 15000 }).catch(() => {});
  return (await page.locator(addressIdentifier).filter({ hasText: marker }).count()) > 0;
};

// CONFIRMED (live, MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08): MIPA enforces a
// genuine one-address-per-type limit (a user can only ever have one
// "billing" address at a time) - the create silently fails server-side
// (a 403, misleadingly) whenever the account already has one, which is
// true by default for this suite's own test account. Rather than the
// scenario just failing there forever, this frees up capacity from
// whichever existing address is "using" the type under test (by editing
// it to drop just that type, keeping any other type it also has) and
// retries the create ONCE - remembering that address so a later step can
// restore it. For any tenant without this limit (the common case) the
// very first attempt already persists, so nothing here ever touches an
// existing address - this is a no-op safety net, not a MIPA-specific
// branch, and needs no per-tenant tagging per CLAUDE.md's shared-suite
// conventions.
When(
  /^I add a new "([^"]*)" address, remembering its last name as "([^"]*)" and any freed-up address as "([^"]*)", retrying once if needed:$/,
  async function (this: ScenarioWorld, addressType: string, rememberAs: string, freedMarkerVariable: string, table: DataTable) {
    const { screen: { page }, globalConfig } = this;
    const fields = table.rowsHash();

    let lastName = `qa-${Date.now()}`;
    await fillNewAddressForm(page, globalConfig, addressType, fields, lastName);

    if (await addressIsPersisted(page, globalConfig, lastName)) {
      this.globalVariables[rememberAs] = lastName;
      this.globalVariables[freedMarkerVariable] = "";
      return;
    }

    // Not persisted - look for an existing address that already has this
    // type selected, and free up capacity by removing just that type from it.
    const addressIdentifier = getElementLocator(page, "address entry", globalConfig);
    const entries = page.locator(addressIdentifier);
    const entryCount = await entries.count();
    let freedMarker: string | null = null;
    let sawSingleTypeOnlyMatch = false;

    for (let i = 0; i < entryCount; i++) {
      const entry = entries.nth(i);
      // The "address entry" selector also matches the page's own read-only
      // "CUSTOMER" info block (confirmed live, MIPA_ADMIN_RELEASE 2.8.0,
      // 2026-09-08: it's rendered as an <address> tag too, ahead of the
      // real address list) - that one has no following-sibling Edit
      // button at all, unlike every genuine address entry, so skip it
      // rather than timing out trying to click a button that isn't there.
      const editButton = entry.locator("xpath=following-sibling::button[1]");
      if ((await editButton.count()) === 0) {
        continue;
      }
      // Capture the marker BEFORE clicking Edit - confirmed live
      // (MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08): the read-only <address>
      // block is replaced entirely by the inline edit form once opened
      // (no ".address-name" left inside it to read back afterwards).
      const markerBeforeEdit = (await entry.locator(".address-name").textContent())?.trim() ?? null;

      await editButton.click();
      await page.waitForTimeout(500);

      const chip = page.locator(`[data-testid='${addressType.toLowerCase()}-multiselect-tag']`);
      if ((await chip.count()) === 0) {
        await page.locator("button:visible", { hasText: "Close" }).first().click();
        continue;
      }

      const totalChips = await page.locator("[data-testid$='-multiselect-tag']").count();
      if (totalChips <= 1) {
        // This address only has "addressType" and nothing else - stripping
        // it would leave a real address with zero types, so skip it and
        // keep looking rather than giving up on the very first match. An
        // account can have several addresses tagged with the same type
        // (confirmed live, Keylite_ADMIN_RELEASE, 2026-09-14: 11 addresses
        // on one account) - an earlier one being untouchable doesn't mean
        // a later one is too.
        sawSingleTypeOnlyMatch = true;
        await page.locator("button:visible", { hasText: "Close" }).first().click();
        continue;
      }

      freedMarker = markerBeforeEdit;
      await chip.locator("xpath=following-sibling::div[contains(@class,'multi-value__remove')][1]").click();
      await clickElement(page, getElementLocator(page, "Save Address", globalConfig));
      await page.waitForTimeout(1000);
      break;
    }

    if (!freedMarker) {
      if (sawSingleTypeOnlyMatch) {
        throw new Error(
          `Adding a new "${addressType}" address was rejected (likely a one-per-type limit), and every existing address ` +
          `with "${addressType}" selected has it as its ONLY type - refusing to strip any of them down to zero types automatically.`
        );
      }
      throw new Error(
        `Adding a new "${addressType}" address was rejected, but no existing address with "${addressType}" already ` +
        `selected could be found to free up capacity from - this isn't the known one-per-type limit, investigate live.`
      );
    }

    lastName = `qa-${Date.now()}`;
    await fillNewAddressForm(page, globalConfig, addressType, fields, lastName);
    if (!(await addressIsPersisted(page, globalConfig, lastName))) {
      throw new Error(`Adding a new "${addressType}" address still failed even after freeing capacity from "${freedMarker}".`);
    }

    this.globalVariables[rememberAs] = lastName;
    this.globalVariables[freedMarkerVariable] = freedMarker;
  }
);

// Undoes the capacity-freeing above, if it happened - restores the given
// address type onto whichever address it was borrowed from, so the
// account is left exactly as it was before this scenario ran. A no-op
// when nothing was freed (the common, non-MIPA case).
When(
  /^I restore "([^"]*)" to the address remembered as "([^"]*)", if any was freed$/,
  async function (this: ScenarioWorld, addressType: string, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const marker = this.globalVariables[variableName];
    if (!marker) return;

    await page.reload({ waitUntil: "domcontentloaded" });
    const addressIdentifier = getElementLocator(page, "address entry", globalConfig);
    const entry = page.locator(addressIdentifier).filter({ hasText: marker });
    await entry.first().waitFor({ state: "visible", timeout: 15000 });
    await entry.first().locator("xpath=following-sibling::button[1]").click();
    await page.waitForTimeout(500);

    await selectAddressTypeReactSelect(page, globalConfig, "Address Type", addressType);
    await clickElement(page, getElementLocator(page, "Save Address", globalConfig));
    await page.waitForTimeout(1000);
  }
);
