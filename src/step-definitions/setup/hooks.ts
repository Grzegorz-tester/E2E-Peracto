import { Before, After, ITestCaseHookParameter, setDefaultTimeout, BeforeStep } from '@cucumber/cucumber';
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

BeforeStep(async function (this: ScenarioWorld, scenario: ITestStepHookParameter) {
    console.log(`🥒 Running cucumber step: "${scenario.pickleStep.text}"`);
});

Before(async function (this: ScenarioWorld, scenario: ITestCaseHookParameter) {
    const scenarioName = sanitize(scenario.pickle.name);
    console.log(`🥒 Running cucumber "${scenario.pickle.name}"`);

    // Ensure the video directory exists
    const videoDir = path.join(env('VIDEO_PATH'), scenarioName);
    if (!fs.existsSync(videoDir)) {
        fs.mkdirSync(videoDir, { recursive: true });
    }

    const contextOptions = {
        recordVideo: {
            dir: videoDir,
        },
    };

    try {
        const ready = await this.init(contextOptions);
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
            const screenshotDir = env('SCREENSHOT_PATH');
            if (!fs.existsSync(screenshotDir)) {
                fs.mkdirSync(screenshotDir, { recursive: true });
            }
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
