import dotenv from 'dotenv'
import path from 'path'
import reporter, { Options } from 'cucumber-html-reporter'
import { env } from '../env/parseEnv'

dotenv.config({path: env('COMMON_CONFIG_FILE', 'env/common.env')})

// Derived from COMMON_CONFIG_FILE's own filename (e.g. "PizzaExpressLive"
// from env/PizzaExpressLive.env) rather than the PROJECT env var - PROJECT
// is only set by projects needing per-project credential overrides (see
// loadGlobalConfig.ts), so it's blank for several projects, while every
// run always sets COMMON_CONFIG_FILE.
const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env')
const today = new Date().toISOString().slice(0, 10)

const options: Options = {
    theme: 'bootstrap',
    jsonFile: env('JSON_REPORT_FILE'),
    output: env('HTML_REPORT_FILE'),
    screenshotsDirectory: env('SCREENSHOT_PATH'),
    storeScreenshots: true,
    reportSuiteAsScenarios: true,
    launchReport: false,
    name: projectName,
    brandTitle: `${projectName} - ${today}`,
}

reporter.generate(options)