"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parsePrice = void 0;
// Currency-symbol-agnostic and decimal/thousands-separator-agnostic - shared
// by every step that needs to compare prices (basket totals, PLP card
// prices), since different storefronts in this framework format prices
// differently even though the underlying testids/selectors are the same
// shape ("£1,234.56" vs "1.234,56 €" etc).
const parsePrice = text => {
  const match = text?.match(/[\d.,]*\d/);
  if (!match) {
    throw new Error(`Could not parse a price out of "${text}"`);
  }
  const raw = match[0];
  const lastComma = raw.lastIndexOf(",");
  const lastDot = raw.lastIndexOf(".");
  const normalized = lastComma > lastDot ? raw.replace(/\./g, "").replace(",", ".") : raw.replace(/,/g, "");
  return parseFloat(normalized);
};
exports.parsePrice = parsePrice;