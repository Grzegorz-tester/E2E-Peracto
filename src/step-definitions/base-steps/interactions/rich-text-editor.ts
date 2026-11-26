import { When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { ElementKey } from "../../../env/global";

// Types into a CKEditor 5 (or any contenteditable) rich text editor with real
// key events. Playwright's fill() on a contenteditable swaps the DOM text
// without going through the editor's own input pipeline, so CKEditor's model
// (what actually gets saved) can miss it. Clicking in, selecting all and
// typing is what a person does, and what CKEditor reliably picks up.
//
// "in bold" toggles bold with the keyboard shortcut before typing, so the
// saved HTML should carry a <strong> - a cheap check that the editor's
// command layer (not just plain text input) survived an editor upgrade
// (PER3-279: CKEditor 34 -> 49 alongside React 16 -> 19).
//
// The element key should point at the editable itself
// (".ck-editor__editable"), mapped per project.
When(
    /^I type "([^"]*)"( in bold)? into the "([^"]*)" rich text editor$/,
    async function (this: ScenarioWorld, text: string, bold: string | undefined, elementKey: ElementKey) {
        const { screen: { page }, globalConfig } = this;
        const selector = getElementLocator(page, elementKey, globalConfig);
        const editor = page.locator(selector).first();

        await editor.waitFor({ state: "visible", timeout: 15000 });
        await editor.click();
        await page.keyboard.press("ControlOrMeta+A");
        await page.keyboard.press("Backspace");
        if (bold) await page.keyboard.press("ControlOrMeta+B");
        await page.keyboard.type(text);
        if (bold) await page.keyboard.press("ControlOrMeta+B");
    },
);
