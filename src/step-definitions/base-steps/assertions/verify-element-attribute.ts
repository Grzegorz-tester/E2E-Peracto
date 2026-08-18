import { Then } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { expect } from "@playwright/test";
import { ElementKey } from "../../../env/global";

// For a raw HTML attribute (placeholder, data-*, etc.) rather than an
// element's text/value - e.g. asserting a field's placeholder copy, or a
// header link's live item-count via a data-* attribute.
Then(
    /^the "([^"]*)" should have attribute "([^"]*)" with value "([^"]*)"$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, attribute: string, expectedValue: string) {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
        await expect(page.locator(elementIdentifier)).toHaveAttribute(attribute, expectedValue, { timeout: 15000 });
    }
);

// For a CSS-class-driven state a site toggles via JS rather than a
// dedicated data-testid/aria attribute - e.g. Watco's ".is-invalid" on a
// rejected VAT number, or ".js-vat-apply-group--dirty" on an edited-but-
// not-yet-applied field. Matches by substring (classList contains, not
// className equals) since real elements carry several classes at once.
Then(
    /^the "([^"]*)" should( not)? have class "([^"]*)"$/,
    async function (this: ScenarioWorld, elementKey: ElementKey, negate: boolean, className: string) {
        const { screen: { page }, globalConfig } = this;
        const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
        const locator = page.locator(elementIdentifier);
        if (negate) {
            await expect(locator).not.toHaveClass(new RegExp(className), { timeout: 15000 });
        } else {
            await expect(locator).toHaveClass(new RegExp(className), { timeout: 15000 });
        }
    }
);
