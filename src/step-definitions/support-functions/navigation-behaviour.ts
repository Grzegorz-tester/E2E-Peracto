import {GlobalConfig, PageId} from "../../env/global";
import {Page} from "playwright";

export const navigateToPage = async (
    page: Page,
    pageId: PageId,
    {pagesConfig, hostsConfig}: GlobalConfig
): Promise<void> => {
    const {
        UI_AUTOMATION_HOST: hostName = 'release_branch',
    } = process.env;

    const hostPath = hostsConfig[`${hostName}`];

    const url = new URL(hostPath);

    const pageConfigItem = pagesConfig[pageId];
    url.pathname = pageConfigItem.route;

    await page.goto(url.href);
};

const pathMatchesPageId = (
    path: string,
    pageId: PageId,
    {pagesConfig}: GlobalConfig
): boolean => {
    const pagesRegexString = pagesConfig[pageId].regex

    const pageRegex = new RegExp(pagesRegexString);

    return pageRegex.test(path);
}

export const currentPathMatchesPageId = (
    page: Page,
    pageId: PageId,
    globalConfig: GlobalConfig,
): boolean => {
    const {pathname: currentPath} = new URL(page.url());

    console.log("currentPath ", currentPath)

    return pathMatchesPageId(currentPath, pageId, globalConfig);
}

export const getCurrentPageId = (
    page: Page,
    globalConfig: GlobalConfig,
): PageId => {
    const {pagesConfig} = globalConfig;

    const pageConfigPageIds = Object.keys(pagesConfig);

    const {pathname: currentPath} = new URL(page.url());

    console.log("pathname ", currentPath)

    const currentPageId = pageConfigPageIds.find(pageId =>
        pathMatchesPageId(currentPath, pageId, globalConfig));

    if (!currentPageId) {
        throw Error(
            `Failed to find page name from current route: ${currentPath}, 
            possible pages: ${JSON.stringify(pagesConfig)}`
        );
    }
    return currentPageId;
}

// Temporary functions till I figure out how to create a regex for the page url
const routeMatchesPageIdRoute = (
    path: string,
    pageId: PageId,
    {pagesConfig}: GlobalConfig
): boolean => {
    return pagesConfig[pageId].route === path;
}
export const currentPathMatchesPageIdRoute = (
    page: Page,
    pageId: PageId,
    globalConfig: GlobalConfig,
): boolean => {
    const {pathname: currentPath} = new URL(page.url());

    console.log("currentPath ", currentPath)

    return routeMatchesPageIdRoute(currentPath, pageId, globalConfig);
}