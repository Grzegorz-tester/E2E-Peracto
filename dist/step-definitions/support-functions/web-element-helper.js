"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.getElementLocator = void 0;
var _navigationBehaviour = require("./navigation-behaviour");
const getElementLocator = (page, elementKey, globalConfig) => {
  const currentPage = (0, _navigationBehaviour.getCurrentPageId)(page, globalConfig);
  const {
    pageElementMappings
  } = globalConfig;
  return pageElementMappings[currentPage]?.[elementKey] || pageElementMappings.common?.[elementKey];
};

// export const countItems = (
//     elementIdentifier: ElementLocator,
//     globalConfig: GlobalConfig,
//     ): number => {
//     const items = ;
//     return items.length;
// }
exports.getElementLocator = getElementLocator;