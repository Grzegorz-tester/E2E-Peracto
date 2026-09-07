import {Locator, Page} from "playwright";
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

// Snapshots what a Locator actually resolves to right now, for use in a
// failure's "Found:" line - e.g. a mapping key/locator still matching
// SOMETHING on the page (just not what the scenario expects, because the
// site's copy or state changed) reads very differently from it matching
// nothing at all. Deliberately doesn't use waitFor/auto-retry: this only
// ever runs once a real failure has already happened, to describe the
// state at that moment, not to wait for a different one. Every check below
// is wrapped so a diagnostic-gathering failure (e.g. the page navigating
// away mid-inspection) degrades to a plain message instead of masking the
// real error. Takes a Locator (rather than a page + CSS string) so it also
// covers call sites built on Playwright's own chained/composed locators -
// a positional `.first()`, a `frameLocator(...).locator(...)` reaching
// inside an iframe - not just a plain mapping-config selector.
export const describeLocator = async (
    locator: Locator,
    label: string,
): Promise<string> => {
    try {
        const count = await locator.count();
        if (count === 0) {
            return `no element matched ${label}`;
        }

        const first = locator.first();
        const [visible, enabled, rawText] = await Promise.all([
            first.isVisible().catch(() => false),
            first.isEnabled().catch(() => false),
            first.textContent().catch(() => null),
        ]);
        const text = rawText?.replace(/\s+/g, " ").trim();
        const countNote = count > 1 ? ` (${count} matches, describing the 1st)` : "";
        const textNote = text ? ` with text "${text.length > 120 ? `${text.slice(0, 120)}…` : text}"` : " with no text content";

        return `matched ${label}${countNote}, ${visible ? "visible" : "not visible"}, ${enabled ? "enabled" : "disabled"}${textNote}`;
    } catch (error) {
        return `could not inspect ${label} (${error instanceof Error ? error.message : String(error)})`;
    }
}

// The common case of describeLocator above - a plain mapping-config CSS/
// testid selector resolved against the top-level page.
export const describeElement = (
    page: Page,
    elementIdentifier: ElementLocator,
): Promise<string> => {
    if (!elementIdentifier) {
        return Promise.resolve("no selector was resolved for this element key - check the project's mapping config");
    }
    return describeLocator(page.locator(elementIdentifier), `"${elementIdentifier}"`);
}

// export const countItems = (
//     elementIdentifier: ElementLocator,
//     globalConfig: GlobalConfig,
//     ): number => {
//     const items = ;
//     return items.length;
// }