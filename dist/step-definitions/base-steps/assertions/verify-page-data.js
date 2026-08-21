"use strict";

var _cucumber = require("@cucumber/cucumber");
var _test = require("@playwright/test");
// Next.js embeds its own server-fetched props as a JSON blob in
// <script id="__NEXT_DATA__">, readable via window.__NEXT_DATA__ once the
// page has loaded - no network interception needed. Stored as a JSON
// string (globalVariables is string-only) rather than parsed here, since
// different Then steps need it in different shapes (a raw substring
// search vs. a resolved field path).
(0, _cucumber.When)(/^I read window\.__NEXT_DATA__$/, async function () {
  const {
    screen: {
      page
    }
  } = this;

  // Confirmed live: a client-side Next.js route transition (clicking a
  // <Link>, not a full page.goto) updates the URL before it finishes
  // replacing window.__NEXT_DATA__ - reading it immediately after a
  // "should be redirected to ..." URL check can still capture the
  // PREVIOUS page's data. Waiting for network idle first (the client
  // fetch that populates the new page's props) avoids that race.
  await page.waitForLoadState("networkidle", {
    timeout: 15000
  }).catch(() => {});
  const nextData = await page.evaluate(() => window.__NEXT_DATA__);
  if (nextData === undefined) {
    throw new Error("window.__NEXT_DATA__ is not present on this page - is it actually a Next.js page?");
  }
  this.globalVariables["__NEXT_DATA__"] = JSON.stringify(nextData);
});

// For confirming which backend a page's data came from (e.g. the live API
// host referenced inside a product's own @id/canonical field), without
// needing to know exactly which field carries it.
(0, _cucumber.Then)(/^the page data should reference "([^"]*)"$/, async function (expectedSubstring) {
  const raw = this.globalVariables["__NEXT_DATA__"];
  if (!raw) {
    throw new Error(`No __NEXT_DATA__ captured - "I read window.__NEXT_DATA__" must run first.`);
  }
  (0, _test.expect)(raw).toContain(expectedSubstring);
});

// Resolves a dot/bracket path (e.g. "props.pageProps.event.childEvents[0].seatsAvailable")
// against the captured __NEXT_DATA__ and asserts it's present and non-empty
// (covers both "field missing" and "field present but blank/zero-length").
(0, _cucumber.Then)(/^the page data at "([^"]*)" should be present$/, async function (fieldPath) {
  const raw = this.globalVariables["__NEXT_DATA__"];
  if (!raw) {
    throw new Error(`No __NEXT_DATA__ captured - "I read window.__NEXT_DATA__" must run first.`);
  }
  const data = JSON.parse(raw);
  const segments = fieldPath.replace(/\[(\d+)\]/g, ".$1").split(".").filter(Boolean);
  let value = data;
  for (const segment of segments) {
    if (value === null || value === undefined) break;
    value = value[segment];
  }
  const isPresent = value !== undefined && value !== null && value !== "" && !(Array.isArray(value) && value.length === 0);
  (0, _test.expect)(isPresent, `Expected "${fieldPath}" to be present in __NEXT_DATA__, got: ${JSON.stringify(value)}`).toBe(true);
});

// For an array field where each entry should carry a given key (e.g. every
// childEvents entry should have its own seatsAvailable) - "at [0]" alone
// wouldn't confirm the shape holds across every date/variant, just the
// first one.
(0, _cucumber.Then)(/^every entry in the page data at "([^"]*)" should have a "([^"]*)" field$/, async function (arrayPath, key) {
  const raw = this.globalVariables["__NEXT_DATA__"];
  if (!raw) {
    throw new Error(`No __NEXT_DATA__ captured - "I read window.__NEXT_DATA__" must run first.`);
  }
  const data = JSON.parse(raw);
  const segments = arrayPath.split(".").filter(Boolean);
  let value = data;
  for (const segment of segments) {
    if (value === null || value === undefined) break;
    value = value[segment];
  }
  (0, _test.expect)(Array.isArray(value), `Expected "${arrayPath}" to be an array, got: ${JSON.stringify(value)}`).toBe(true);
  const entries = value;
  (0, _test.expect)(entries.length, `Expected "${arrayPath}" to have at least one entry`).toBeGreaterThan(0);
  const missing = entries.filter(entry => entry?.[key] === undefined);
  (0, _test.expect)(missing, `Entries missing "${key}": ${JSON.stringify(missing)}`).toEqual([]);
});