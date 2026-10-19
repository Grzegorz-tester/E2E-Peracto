import { Before, BeforeAll, After, ITestCaseHookParameter, setDefaultTimeout, BeforeStep, AfterStep } from '@cucumber/cucumber';
import { env } from '../../env/parseEnv';
import { ScenarioWorld } from './world';
import { detectBlockPage, blockPageMessage } from '../support-functions/block-page-detection';
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
// tenants sharing the CARBON_ADMIN_SHARED_features suite) silently overwrote each other's
// screenshot.
const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env');
const screenshotDir = path.join(env('SCREENSHOT_PATH'), projectName);

BeforeAll(async function () {
    // Reset this project's screenshot folder once per run, not once per
    // scenario - without this, a scenario that used to fail (and was since
    // fixed) left its old failure screenshot behind forever, since nothing
    // else ever removed a screenshot once written.
    // With PARALLEL > 1, BeforeAll runs once in EVERY worker process, so only
    // worker 0 wipes - otherwise a slower-starting worker could delete
    // screenshots another worker had already captured.
    const workerId = process.env.CUCUMBER_WORKER_ID;
    if (workerId === undefined || workerId === '0') {
        fs.rmSync(screenshotDir, { recursive: true, force: true });
    }
    fs.mkdirSync(screenshotDir, { recursive: true });
});

BeforeStep(async function (this: ScenarioWorld, scenario: ITestStepHookParameter) {
    console.log(`🥒 Running cucumber step: "${scenario.pickleStep.text}"`);
});

// Fail fast, with a clear message, when the site's WAF serves its block
// page instead of the real one (see block-page-detection.ts). An AfterStep
// error fails the step it ran after, so the scenario goes red on the
// navigation step that got blocked - not 15-20s later on whichever selector
// timed out first. A step that already failed keeps its own error; the
// block is attached as a note alongside it instead.
AfterStep(async function (this: ScenarioWorld, { result }: ITestStepHookParameter) {
    const page = this.screen?.page;
    const blockedText = await detectBlockPage(page);
    if (!blockedText) return;

    const message = blockPageMessage(page.url(), blockedText);
    if (result?.status === 'PASSED') {
        throw new Error(message);
    }
    await this.attach(message, 'text/plain');
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
            fs.mkdirSync(screenshotDir, { recursive: true });
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
