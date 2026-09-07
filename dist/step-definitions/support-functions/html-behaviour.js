"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.withActionDiagnostics = exports.uncheckElement = exports.selectDropdownOption = exports.getValue = exports.enterValue = exports.clickElementAtIndex = exports.clickElement = exports.checkElement = void 0;
var _webElementHelper = require("./web-element-helper");
// getElementLocator returns undefined (not a string) when an element key
// has no mapping entry for the current page/common.json - quoting that
// directly would read as the literal text "undefined" rather than
// explaining the actual problem (a missing mapping), which is a much more
// useful thing for whoever's reading the failure to see.
const describeIdentifier = elementIdentifier => elementIdentifier ? `"${elementIdentifier}"` : "<no selector resolved for this element key - check the project's mapping config>";

// Wraps ANY async action (not just the page/selector-shaped ones below) so
// its failure reports an Expected/Found pair alongside the original error -
// not instead of it, since the original still carries Playwright's own
// timeout/actionability detail. `describeActual` is only invoked once the
// action has already failed, purely for diagnostics - never used to decide
// whether to retry. Exported for interaction steps that operate on a
// Playwright Locator chain (a `.first()`, a `frameLocator(...).locator(...)`
// reaching inside an iframe) rather than a plain mapping-config CSS string,
// which the selector-specific withDiagnostics below can't describe on its
// own - those steps build their own describeActual via describeLocator and
// call this directly instead.
const withActionDiagnostics = async (expected, describeActual, action) => {
  try {
    return await action();
  } catch (error) {
    const actual = await describeActual().catch(describeError => `could not inspect the page after the failure (${describeError instanceof Error ? describeError.message : String(describeError)})`);
    const originalMessage = error instanceof Error ? error.message : String(error);
    const enriched = new Error(`Expected: ${expected}\nFound: ${actual}\n\n${originalMessage}`);
    if (error instanceof Error && error.stack) enriched.stack = error.stack;
    throw enriched;
  }
};

// The common case of withActionDiagnostics above - a plain mapping-config
// CSS/testid selector resolved against the top-level page. Centralised here
// rather than in each step definition because clickElement/enterValue/
// checkElement/selectDropdownOption are the shared primitives nearly every
// interaction step in the framework calls into, so wrapping them once gives
// every one of those steps richer failure output for free.
exports.withActionDiagnostics = withActionDiagnostics;
const withDiagnostics = (page, elementIdentifier, expected, action) => withActionDiagnostics(expected, () => (0, _webElementHelper.describeElement)(page, elementIdentifier), action);
const clickElement = async (page, elementIdentifier, options) => {
  await withDiagnostics(page, elementIdentifier, `to click ${describeIdentifier(elementIdentifier)}`, () => page.click(elementIdentifier, options));
};
exports.clickElement = clickElement;
const clickElementAtIndex = async (page, elementIdentifier, elementPosition, options) => {
  // Locate all elements matching the identifier
  const elements = await page.$$(elementIdentifier);

  // Check if the specified index is within bounds
  if (elementPosition >= elements.length) {
    throw new Error(`Expected: to click index ${elementPosition} of ${describeIdentifier(elementIdentifier)}\nFound: only ${elements.length} matching element(s)`);
  }

  // Click the specific instance of the element by its index
  const element = elements[elementPosition];
  await withDiagnostics(page, elementIdentifier, `to click index ${elementPosition} of ${describeIdentifier(elementIdentifier)}`, () => element.click(options));
};
exports.clickElementAtIndex = clickElementAtIndex;
const enterValue = async (page, elementIdentifier, inputText) => {
  await withDiagnostics(page, elementIdentifier, `to fill ${describeIdentifier(elementIdentifier)} with "${inputText}"`, async () => {
    await page.focus(elementIdentifier);
    await page.fill(elementIdentifier, inputText);
  });
};

// Tries matching by the option's `value` attribute first (Playwright's
// default for a plain string), falling back to its visible label text if
// that throws - a select whose values are opaque (a country dropdown's
// "GB"/"DE"/etc., not the visible "United Kingdom"/"Deutschland" text)
// would otherwise never match a feature file's human-readable option text.
// Existing callers where value === label (common for e.g. "Sort by"
// dropdowns) are unaffected - the first attempt already succeeds for them.
exports.enterValue = enterValue;
const selectDropdownOption = async (page, elementIdentifier, option) => {
  await withDiagnostics(page, elementIdentifier, `to select option "${option}" on ${describeIdentifier(elementIdentifier)}`, async () => {
    await page.focus(elementIdentifier);
    try {
      await page.selectOption(elementIdentifier, option);
    } catch {
      await page.selectOption(elementIdentifier, {
        label: option
      });
    }
  });
};

// force: true, matching clickElement's own reasoning (see click.ts's top
// comment) - a checkbox styled via a custom label/icon over a visually
// hidden native input (confirmed live: Watco's marketing-agreement
// checkbox) otherwise fails Playwright's "visible"/"receives events"
// actionability checks even though a real click at that location works
// fine. force still requires the element to be attached, so a genuinely
// missing checkbox still fails loudly.
exports.selectDropdownOption = selectDropdownOption;
const checkElement = async (page, elementIdentifier) => {
  await withDiagnostics(page, elementIdentifier, `to check ${describeIdentifier(elementIdentifier)}`, () => page.check(elementIdentifier, {
    force: true
  }));
};

// The uncheck counterpart to checkElement above - Playwright's own
// page.uncheck() is already idempotent (a no-op if the box/switch is
// already unchecked), the same property that makes .check() safe to call
// unconditionally elsewhere in this framework. Needed for a real toggle
// (e.g. a VAT-inclusive/exclusive switch) where a scenario must set a KNOWN
// state in either direction, not just turn something on.
exports.checkElement = checkElement;
const uncheckElement = async (page, elementIdentifier) => {
  await withDiagnostics(page, elementIdentifier, `to uncheck ${describeIdentifier(elementIdentifier)}`, () => page.uncheck(elementIdentifier, {
    force: true
  }));
};
exports.uncheckElement = uncheckElement;
const getValue = async (page, elementIdentifier) => {
  const value = await page.$eval(elementIdentifier, el => {
    return el.value;
  });
  return value;
};
exports.getValue = getValue;