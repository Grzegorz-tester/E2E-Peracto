import { Before, BeforeAll, After, ITestCaseHookParameter, setDefaultTimeout, BeforeStep } from '@cucumber/cucumber';
import { env } from '../../env/parseEnv';
import { ScenarioWorld } from './world';
import { ITestStepHookParameter } from "@cucumber/cucumber/lib/support_code_library_builder/types";
import fs from 'fs';
import path from 'path';

// Utility: sanitize names for safe file and directory usage
function sanitize(name: string): string {
    return name.replace(/[<>:"/\\|?*]/g, '_').replace(/ /g, '_');
}

setDefaultTimeout(Number(env('SCRIPT_TIMEOUT')));

// Same projectName derivation the reporters use, so a project's own
// failure screenshots live in their own subfolder - screenshots are keyed
// only by scenario name (see sanitize() below), so a flat shared directory
// meant two projects with an identically-named scenario (e.g. any pair of
// tenants sharing the Carbon_admin suite) silently overwrote each other's
// screenshot.
const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env');
const screenshotDir = path.join(env('SCREENSHOT_PATH'), projectName);

BeforeAll(async function () {
    // Reset this project's screenshot folder once per run, not once per
    // scenario - without this, a scenario that used to fail (and was since
    // fixed) left its old failure screenshot behind forever, since nothing
    // else ever removed a screenshot once written.
    fs.rmSync(screenshotDir, { recursive: true, force: true });
    fs.mkdirSync(screenshotDir, { recursive: true });
});

BeforeStep(async function (this: ScenarioWorld, scenario: ITestStepHookParameter) {
    console.log(`🥒 Running cucumber step: "${scenario.pickleStep.text}"`);
});

Before(async function (this: ScenarioWorld, scenario: ITestCaseHookParameter) {
    console.log(`🥒 Running cucumber "${scenario.pickle.name}"`);

    try {
        const ready = await this.init();
        return ready;
    } catch (err) {
        console.error('Error during scenario setup:', err);
        throw err;
    }
});

After(async function (this: ScenarioWorld, scenario: ITestCaseHookParameter) {
    const {
        screen: { page, browser },
    } = this;
    const scenarioStatus = scenario.result?.status;
    const scenarioName = sanitize(scenario.pickle.name);

    if (scenarioStatus === 'FAILED') {
        try {
            const screenshotPath = path.join(screenshotDir, `${scenarioName}.png`);
            const screenshot = await page.screenshot({ path: screenshotPath });
            await this.attach(screenshot, 'image/png');
        } catch (err) {
            console.error('Error capturing screenshot:', err);
        }
    }

    try {
        await browser.close();
    } catch (err) {
        console.error('Error closing browser:', err);
    }
});
