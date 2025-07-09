import {Page} from "playwright";
import {ElementKey, ElementLocator, GlobalConfig} from "../../env/global";
import {getCurrentPageId} from "./navigation-behaviour";

export const getElementLocator = (
    page: Page,
    elementKey: ElementKey,
    globalConfig: GlobalConfig,
): ElementLocator => {
    const currentPage = getCurrentPageId(page, globalConfig);

    const {pageElementMappings} = globalConfig;

    return pageElementMappings[currentPage]?.[elementKey] || pageElementMappings.common?.[elementKey]
}

// export const countItems = (
//     elementIdentifier: ElementLocator,
//     globalConfig: GlobalConfig,
//     ): number => {
//     const items = ;
//     return items.length;
// }