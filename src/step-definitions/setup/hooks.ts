import { Before, BeforeAll, After, ITestCaseHookParameter, setDefaultTimeout, BeforeStep, AfterStep, HookTarget } from '@cucumber/cucumber';
import { env } from '../../env/parseEnv';
import { ScenarioWorld } from './world';
import { detectBlockPage, blockPageMessage } from '../support-functions/block-page-detection';
import { isProductionRun, PRODUCTION_UNSAFE_TAGS } from '../../env/run-environment';
import { RETRY_PASS_MARKER } from '../../env/report-markers';
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

BeforeAll({ on: HookTarget.COORDINATOR }, async function () {
    // Reset this project's screenshot folder once per run, not once per
    // scenario - without this, a scenario that used to fail (and was since
    // fixed) left its old failure screenshot behind forever, since nothing
    // else ever removed a screenshot once written.
    // In parallel mode a plain BeforeAll runs once in EVERY worker, and even
    // limiting the wipe to worker 0 could still delete a screenshot another,
    // faster worker had already captured. A COORDINATOR hook runs exactly
    // once, before any worker starts (and as a normal BeforeAll when not
    // running in parallel).
    fs.rmSync(screenshotDir, { recursive: true, force: true });
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

// RETRY (env/*.env) reruns a failed scenario, but cucumber's JSON report
// keeps only the final attempt - so a scenario that failed and then passed
// looked identical to a clean pass, hiding real instability. Count attempts
// per pickle in a Before hook (retries always run in the same worker as the
// first attempt; cucumber hasn't decided willBeRetried yet when After hooks
// run, so that flag can't be used) and attach a marker to a passing attempt
// that wasn't the first; the PDF report and console summary pick it up via
// RETRY_PASS_MARKER.
const attemptsByPickle = new Map<string, number>();

Before(async function (scenario: ITestCaseHookParameter) {
    attemptsByPickle.set(scenario.pickle.id, (attemptsByPickle.get(scenario.pickle.id) ?? 0) + 1);
});

// Hard production gate. The profiles in src/index.ts already filter these
// tags out of every production run, but that only protects runs that go
// through a profile - an ad hoc `cucumber-js --tags ...` or a custom profile
// bypasses it (how real orders reached KOOLTECH prod on 2026-09-11). This
// runs before the browser even opens, so an unsafe scenario on a production
// run fails immediately with nothing touched, however the run was started.
Before(async function (scenario: ITestCaseHookParameter) {
    if (!isProductionRun()) return;
    const unsafe = scenario.pickle.tags.map(tag => tag.name).filter(tag => PRODUCTION_UNSAFE_TAGS.includes(tag));
    if (unsafe.length > 0) {
        throw new Error(
            `Refusing to run "${scenario.pickle.name}" on production: it is tagged ${unsafe.join(', ')}. ` +
            `Production runs must stay read-only (see CLAUDE.md "Staging vs production rules").`
        );
    }
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
    const page = this.screen?.page;
    const browser = this.screen?.browser;
    const scenarioStatus = scenario.result?.status;
    const scenarioName = sanitize(scenario.pickle.name);

    const attempt = attemptsByPickle.get(scenario.pickle.id) ?? 1;
    if (scenarioStatus === 'PASSED' && attempt > 1) {
        await this.attach(`${RETRY_PASS_MARKER}: failed ${attempt - 1} attempt(s) before passing`, 'text/plain');
    }

    if (scenarioStatus === 'FAILED' && page) {
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
        await browser?.close();
    } catch (err) {
        console.error('Error closing browser:', err);
    }
});
