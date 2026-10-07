import { When, Then } from "@cucumber/cucumber";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import { ElementKey } from "../../../env/global";
import { getElementLocator } from "../../support-functions/web-element-helper";
import { ScenarioWorld } from "../../setup/world";

// Generic, reusable download-capturing step - not specific to any one
// project's export page. Stores both the browser-suggested filename and a
// local path to the saved file under `variableName` (and `variableName`
// + "__path"`) in globalVariables, the same "remembered value" convention
// already used elsewhere (verify-element-value.ts's "I remember the text
// of ... as ...") rather than introducing a separate storage mechanism
// just for downloads.
When(/^I click on the "([^"]*)" button, remembering the downloaded file as "([^"]*)"$/, async function (this: ScenarioWorld, elementKey: ElementKey, variableName: string) {
    const { screen: { page }, globalConfig } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    const [download] = await Promise.all([
        page.waitForEvent("download", { timeout: 20000 }),
        page.click(elementIdentifier),
    ]);

    const savedPath = path.join(os.tmpdir(), `${Date.now()}-${download.suggestedFilename()}`);
    await download.saveAs(savedPath);

    this.globalVariables[variableName] = download.suggestedFilename();
    this.globalVariables[`${variableName}__path`] = savedPath;
});

Then(/^the remembered "([^"]*)" download should be named "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string, expectedFilename: string) {
    const actual = this.globalVariables[variableName];
    if (actual !== expectedFilename) {
        throw new Error(`Expected the "${variableName}" download to be named "${expectedFilename}", but it was named "${actual}"`);
    }
});

Then(/^the remembered "([^"]*)" download should not be empty$/, async function (this: ScenarioWorld, variableName: string) {
    const savedPath = this.globalVariables[`${variableName}__path`];
    const stats = fs.statSync(savedPath);
    if (stats.size === 0) {
        throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) to be non-empty, but it was 0 bytes`);
    }
});

// For a CSV/text export, confirms the file actually contains the expected
// shape (e.g. its header row) rather than just "some bytes" - a download
// that's non-empty but garbled (an error page saved as if it were the
// export) would still pass the "not empty" check above.
Then(/^the remembered "([^"]*)" download should start with the text "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string, expectedPrefix: string) {
    const savedPath = this.globalVariables[`${variableName}__path`];
    const content = fs.readFileSync(savedPath, "utf-8");
    if (!content.startsWith(expectedPrefix)) {
        throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) to start with "${expectedPrefix}", but it started with "${content.slice(0, 200)}"`);
    }
});

// Order-independent alternative to the "should start with the text" step
// above - for a CSV whose header columns are confirmed present but not
// necessarily in the same order on every tenant (e.g. per-tenant custom
// attributes interleaved with the standard ones, rather than only
// appended at the end).
Then(/^the remembered "([^"]*)" download's header row should contain the columns "([^"]*)"$/, async function (this: ScenarioWorld, variableName: string, expectedColumns: string) {
    const savedPath = this.globalVariables[`${variableName}__path`];
    const content = fs.readFileSync(savedPath, "utf-8");
    const headerRow = content.split(/\r?\n/, 1)[0];
    // Strip CSV quoting ("Job Reference" -> Job Reference) so quoted and
    // unquoted headers compare the same.
    const actualColumns = headerRow.split(",").map((column) => column.trim().replace(/^"(.*)"$/, "$1"));
    const missingColumns = expectedColumns.split(",").filter((column) => !actualColumns.includes(column));
    if (missingColumns.length > 0) {
        throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) header row to contain the columns "${missingColumns.join(", ")}", but the header row was "${headerRow}"`);
    }
});

// Checks a downloaded file mentions a value captured earlier in the same
// scenario (e.g. the reference of a job just completed should appear in the
// export that follows), optionally on the same line as some literal text
// (e.g. that job's expected total) - a plain "contains" for each would pass
// even if the two values sat on different rows.
Then(/^the remembered "([^"]*)" download should( not)? contain the remembered "([^"]*)"(?: on a line containing "([^"]*)")?$/, async function (this: ScenarioWorld, variableName: string, negate: string | undefined, rememberedName: string, sameLineText: string | undefined) {
    const savedPath = this.globalVariables[`${variableName}__path`];
    const remembered = this.globalVariables[rememberedName];
    if (savedPath === undefined || remembered === undefined) {
        throw new Error(`Missing remembered download "${variableName}" or value "${rememberedName}".`);
    }
    const lines = fs.readFileSync(savedPath, "utf-8").split(/\r?\n/);
    const found = lines.some((line) => line.includes(remembered) && (sameLineText === undefined || line.includes(sameLineText)));
    if (found === Boolean(negate)) {
        throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) to ${negate ? "not " : ""}contain "${remembered}"${sameLineText ? ` on a line containing "${sameLineText}"` : ""}. First lines: ${lines.slice(0, 5).join(" / ")}`);
    }
});
