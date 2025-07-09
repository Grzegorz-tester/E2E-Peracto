"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.selectDropdownOption = exports.getValue = exports.enterValue = exports.clickElementAtIndex = exports.clickElement = exports.checkElement = void 0;
const clickElement = async (page, elementIdentifier) => {
  await page.click(elementIdentifier);
};
exports.clickElement = clickElement;
const clickElementAtIndex = async (page, elementIdentifier, elementPosition) => {
  // Locate all elements matching the identifier
  const elements = await page.$$(elementIdentifier);

  // Check if the specified index is within bounds
  if (elementPosition >= elements.length) {
    throw new Error(`Element index ${elementPosition} is out of bounds. Only ${elements.length} elements found.`);
  }

  // Click the specific instance of the element by its index
  const element = elements[elementPosition];
  await element.click();
};
exports.clickElementAtIndex = clickElementAtIndex;
const enterValue = async (page, elementIdentifier, inputText) => {
  await page.focus(elementIdentifier);
  await page.fill(elementIdentifier, inputText);
};
exports.enterValue = enterValue;
const selectDropdownOption = async (page, elementIdentifier, option) => {
  await page.focus(elementIdentifier);
  await page.selectOption(elementIdentifier, option);
};
exports.selectDropdownOption = selectDropdownOption;
const checkElement = async (page, elementIdentifier) => {
  await page.check(elementIdentifier);
};
exports.checkElement = checkElement;
const getValue = async (page, elementIdentifier) => {
  const value = await page.$eval(elementIdentifier, el => {
    return el.value;
  });
  return value;
};
exports.getValue = getValue;