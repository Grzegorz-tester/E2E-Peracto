import {Page} from "playwright";
import {ElementLocator} from "../../env/global";
import {describeElement} from "./web-element-helper";

// getElementLocator returns undefined (not a string) when an element key
// has no mapping entry for the current page/common.json - quoting that
// directly would read as the literal text "undefined" rather than
// explaining the actual problem (a missing mapping), which is a much more
// useful thing for whoever's reading the failure to see.
const describeIdentifier = (elementIdentifier: ElementLocator): string =>
    elementIdentifier ? `"${elementIdentifier}"` : "<no selector resolved for this element key - check the project's mapping config>";

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
export const withActionDiagnostics = async <T>(
    expected: string,
    describeActual: () => Promise<string>,
    action: () => Promise<T>,
): Promise<T> => {
    try {
        return await action();
    } catch (error) {
        const actual = await describeActual().catch((describeError) =>
            `could not inspect the page after the failure (${describeError instanceof Error ? describeError.message : String(describeError)})`
        );
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
const withDiagnostics = <T>(
    page: Page,
    elementIdentifier: ElementLocator,
    expected: string,
    action: () => Promise<T>,
): Promise<T> => withActionDiagnostics(expected, () => describeElement(page, elementIdentifier), action);

export const clickElement = async (
    page: Page,
    elementIdentifier: ElementLocator,
    options?: { timeout?: number, force?: boolean },
) => {
    await withDiagnostics(page, elementIdentifier, `to click ${describeIdentifier(elementIdentifier)}`, () =>
        page.click(elementIdentifier, options)
    );
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
        throw new Error(`Expected: to click index ${elementPosition} of ${describeIdentifier(elementIdentifier)}\nFound: only ${elements.length} matching element(s)`);
    }

    // Click the specific instance of the element by its index
    const element = elements[elementPosition];
    await withDiagnostics(page, elementIdentifier, `to click index ${elementPosition} of ${describeIdentifier(elementIdentifier)}`, () =>
        element.click(options)
    );
};



export const enterValue = async (
    page: Page,
    elementIdentifier: ElementLocator,
    inputText: string
) => {
    await withDiagnostics(page, elementIdentifier, `to fill ${describeIdentifier(elementIdentifier)} with "${inputText}"`, async () => {
        await page.focus(elementIdentifier);
        await page.fill(elementIdentifier, inputText);
    });
}

// For a field that auto-populates itself (e.g. an Identifier/slug derived
// from a sibling Label field) the instant it's focused - CONFIRMED live on
// HIB_ADMIN (Peracto Admin's Option Identifier field, 2026-09-13):
// focusing an empty Identifier field alone fills it with the slugified
// Label value, so the plain "enterValue" above (focus then fill) ends up
// filling on top of that just-appeared auto-value rather than an empty
// field - Playwright's own fill() clears via a direct property set, but
// this component's onChange still concatenates onto its own prior state
// instead of the DOM's post-clear value, producing a doubled result
// ("size" typed into an auto-populated "size" becomes "sizesize"). A real
// user never hits this: they either accept the correct auto-value as-is or
// notice and manually clear it before retyping, which this step now does
// too - triple-click selects the field's current content (auto-populated
// or not) and Backspace removes it before typing, so the same generic
// "enterValue" above stays untouched for every field that doesn't have
// this quirk (no reason to slow every fill in the suite down for it).
export const enterValueClearingAutoPopulatedFirst = async (
    page: Page,
    elementIdentifier: ElementLocator,
    inputText: string
) => {
    await withDiagnostics(page, elementIdentifier, `to fill ${describeIdentifier(elementIdentifier)} with "${inputText}" after clearing any auto-populated value`, async () => {
        const locator = page.locator(elementIdentifier);
        await locator.click({ clickCount: 3 });
        await locator.press("Backspace");
        await locator.type(inputText, { delay: 20 });
    });
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
    await withDiagnostics(page, elementIdentifier, `to select option "${option}" on ${describeIdentifier(elementIdentifier)}`, async () => {
        await page.focus(elementIdentifier);
        try {
            await page.selectOption(elementIdentifier, option);
        } catch {
            await page.selectOption(elementIdentifier, { label: option });
        }
    });
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
    await withDiagnostics(page, elementIdentifier, `to check ${describeIdentifier(elementIdentifier)}`, () =>
        page.check(elementIdentifier, { force: true })
    );
}

// The uncheck counterpart to checkElement above - Playwright's own
// page.uncheck() is already idempotent (a no-op if the box/switch is
// already unchecked), the same property that makes .check() safe to call
// unconditionally elsewhere in this framework. Needed for a real toggle
// (e.g. a VAT-inclusive/exclusive switch) where a scenario must set a KNOWN
// state in either direction, not just turn something on.
export const uncheckElement = async (
    page: Page,
    elementIdentifier: ElementLocator,
) => {
    await withDiagnostics(page, elementIdentifier, `to uncheck ${describeIdentifier(elementIdentifier)}`, () =>
        page.uncheck(elementIdentifier, { force: true })
    );
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