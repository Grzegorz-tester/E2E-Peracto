import {When} from "@cucumber/cucumber";
import path from "path";
import {ElementKey} from "../../../env/global";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {ScenarioWorld} from "../../setup/world";

// Fixture files live once under src/features/fixtures/ rather than per-project,
// so any project can reuse the same CSV/file across scenarios (e.g. a Quick
// Order CSV upload) without duplicating test data.
When(/^I upload the "([^"]*)" file to the "([^"]*)" input$/, async function (this: ScenarioWorld, fixtureFile: string, elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);
    const filePath = path.join(process.cwd(), "src/features/fixtures", fixtureFile);

    await page.setInputFiles(elementIdentifier, filePath);
});
