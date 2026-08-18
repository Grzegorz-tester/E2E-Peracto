"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.selectDropdownOption = exports.getValue = exports.enterValue = exports.clickElementAtIndex = exports.clickElement = exports.checkElement = void 0;
const clickElement = async (page, elementIdentifier, options) => {
  await page.click(elementIdentifier, options);
};
exports.clickElement = clickElement;
const clickElementAtIndex = async (page, elementIdentifier, elementPosition, options) => {
  // Locate all elements matching the identifier
  const elements = await page.$$(elementIdentifier);

  // Check if the specified index is within bounds
  if (elementPosition >= elements.length) {
    throw new Error(`Element index ${elementPosition} is out of bounds. Only ${elements.length} elements found.`);
  }

  // Click the specific instance of the element by its index
  const element = elements[elementPosition];
  await element.click(options);
};
exports.clickElementAtIndex = clickElementAtIndex;
const enterValue = async (page, elementIdentifier, inputText) => {
  await page.focus(elementIdentifier);
  await page.fill(elementIdentifier, inputText);
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
  await page.focus(elementIdentifier);
  try {
    await page.selectOption(elementIdentifier, option);
  } catch {
    await page.selectOption(elementIdentifier, {
      label: option
    });
  }
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
  await page.check(elementIdentifier, {
    force: true
  });
};
exports.checkElement = checkElement;
const getValue = async (page, elementIdentifier) => {
  const value = await page.$eval(elementIdentifier, el => {
    return el.value;
  });
  return value;
};
exports.getValue = getValue;