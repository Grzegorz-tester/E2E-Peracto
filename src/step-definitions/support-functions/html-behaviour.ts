import {Page} from "playwright";
import {ElementLocator} from "../../env/global";


export const clickElement = async (
    page: Page,
    elementIdentifier: ElementLocator,
    options?: { timeout?: number, force?: boolean },
) => {
    await page.click(elementIdentifier, options);
}
export const clickElementAtIndex = async (
    page: Page,
    elementIdentifier: ElementLocator,
    elementPosition: number,
    options?: { timeout?: number, force?: boolean },
): Promise<void> => {
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



export const enterValue = async (
    page: Page,
    elementIdentifier: ElementLocator,
    inputText: string
) => {
    await page.focus(elementIdentifier);
    await page.fill(elementIdentifier, inputText);
}

// Tries matching by the option's `value` attribute first (Playwright's
// default for a plain string), falling back to its visible label text if
// that throws - a select whose values are opaque (a country dropdown's
// "GB"/"DE"/etc., not the visible "United Kingdom"/"Deutschland" text)
// would otherwise never match a feature file's human-readable option text.
// Existing callers where value === label (common for e.g. "Sort by"
// dropdowns) are unaffected - the first attempt already succeeds for them.
export const selectDropdownOption = async (
    page: Page,
    elementIdentifier: ElementLocator,
    option: string,
) => {
    await page.focus(elementIdentifier);
    try {
        await page.selectOption(elementIdentifier, option);
    } catch {
        await page.selectOption(elementIdentifier, { label: option });
    }
}

// force: true, matching clickElement's own reasoning (see click.ts's top
// comment) - a checkbox styled via a custom label/icon over a visually
// hidden native input (confirmed live: Watco's marketing-agreement
// checkbox) otherwise fails Playwright's "visible"/"receives events"
// actionability checks even though a real click at that location works
// fine. force still requires the element to be attached, so a genuinely
// missing checkbox still fails loudly.
export const checkElement = async (
    page: Page,
    elementIdentifier: ElementLocator,
) => {
    await page.check(elementIdentifier, { force: true });
}

export const getValue = async (
    page: Page,
    elementIdentifier: ElementLocator,
) => {
    const value = await page.$eval <string, HTMLSelectElement>(elementIdentifier, el => {
        return el.value;
    })
    return value;
}