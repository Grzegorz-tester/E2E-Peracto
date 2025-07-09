import {Page} from "playwright";
import {ElementLocator} from "../../env/global";


export const clickElement = async (
    page: Page,
    elementIdentifier: ElementLocator,
) => {
    await page.click(elementIdentifier);
}
export const clickElementAtIndex = async (
    page: Page,
    elementIdentifier: ElementLocator,
    elementPosition: number
): Promise<void> => {
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



export const enterValue = async (
    page: Page,
    elementIdentifier: ElementLocator,
    inputText: string
) => {
    await page.focus(elementIdentifier);
    await page.fill(elementIdentifier, inputText);
}

export const selectDropdownOption = async (
    page: Page,
    elementIdentifier: ElementLocator,
    option: string,
) => {
    await page.focus(elementIdentifier);
    await page.selectOption(elementIdentifier, option);
}

export const checkElement = async (
    page: Page,
    elementIdentifier: ElementLocator,
) => {
    await page.check(elementIdentifier);
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