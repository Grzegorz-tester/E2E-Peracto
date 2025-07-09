"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.navigateToPage = exports.getCurrentPageId = exports.currentPathMatchesPageIdRoute = exports.currentPathMatchesPageId = void 0;
const navigateToPage = async (page, pageId, _ref) => {
  let {
    pagesConfig,
    hostsConfig
  } = _ref;
  const {
    UI_AUTOMATION_HOST: hostName = 'release_branch'
  } = process.env;
  const hostPath = hostsConfig[`${hostName}`];
  const url = new URL(hostPath);
  const pageConfigItem = pagesConfig[pageId];
  url.pathname = pageConfigItem.route;
  await page.goto(url.href);
};
exports.navigateToPage = navigateToPage;
const pathMatchesPageId = (path, pageId, _ref2) => {
  let {
    pagesConfig
  } = _ref2;
  const pagesRegexString = pagesConfig[pageId].regex;
  const pageRegex = new RegExp(pagesRegexString);
  return pageRegex.test(path);
};
const currentPathMatchesPageId = (page, pageId, globalConfig) => {
  const {
    pathname: currentPath
  } = new URL(page.url());
  console.log("currentPath ", currentPath);
  return pathMatchesPageId(currentPath, pageId, globalConfig);
};
exports.currentPathMatchesPageId = currentPathMatchesPageId;
const getCurrentPageId = (page, globalConfig) => {
  const {
    pagesConfig
  } = globalConfig;
  const pageConfigPageIds = Object.keys(pagesConfig);
  const {
    pathname: currentPath
  } = new URL(page.url());
  console.log("pathname ", currentPath);
  const currentPageId = pageConfigPageIds.find(pageId => pathMatchesPageId(currentPath, pageId, globalConfig));
  if (!currentPageId) {
    throw Error(`Failed to find page name from current route: ${currentPath}, 
            possible pages: ${JSON.stringify(pagesConfig)}`);
  }
  return currentPageId;
};

// Temporary functions till I figure out how to create a regex for the page url
exports.getCurrentPageId = getCurrentPageId;
const routeMatchesPageIdRoute = (path, pageId, _ref3) => {
  let {
    pagesConfig
  } = _ref3;
  return pagesConfig[pageId].route === path;
};
const currentPathMatchesPageIdRoute = (page, pageId, globalConfig) => {
  const {
    pathname: currentPath
  } = new URL(page.url());
  console.log("currentPath ", currentPath);
  return routeMatchesPageIdRoute(currentPath, pageId, globalConfig);
};
exports.currentPathMatchesPageIdRoute = currentPathMatchesPageIdRoute;