import dotenv from 'dotenv'
import path from 'path'
import reporter, { Options } from 'cucumber-html-reporter'
import { env, getJsonFromFile } from '../env/parseEnv'

dotenv.config({path: env('COMMON_CONFIG_FILE', 'env/common.env')})

// Derived from COMMON_CONFIG_FILE's own filename (e.g. "PizzaExpressLive"
// from env/PizzaExpressLive.env) rather than the PROJECT env var - PROJECT
// is only set by projects needing per-project credential overrides (see
// loadGlobalConfig.ts), so it's blank for several projects, while every
// run always sets COMMON_CONFIG_FILE.
const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env')
const today = new Date().toISOString().slice(0, 10)

// Same host lookup loadGlobalConfig.ts does for the step definitions -
// surfaces the actual base URL a run targeted (e.g.
// "https://release-2-8-1.mipa-paints.pub/" for MIPA_RELEASE's
// release_branch host) in the report itself, since a release branch's URL
// gets bumped mid-sprint and the report should say which one was actually
// tested without needing to go check the env file. Falls back to '-'
// rather than throwing - purely cosmetic, shouldn't block report
// generation if the lookup ever fails.
const resolveTargetUrl = (): string => {
    try {
        const hostsConfig = getJsonFromFile<Record<string, string>>(env('HOSTS_URL_PATH'))
        const host = env('UI_AUTOMATION_HOST', 'staging')
        return hostsConfig[host] ?? '-'
    } catch {
        return '-'
    }
}

// cucumber-html-reporter embeds each failure screenshot inline as a base64
// data URI straight from the JSON's step embeddings (see hooks.ts's
// this.attach) regardless of this option - screenshotsDirectory only
// matters as a fallback location the library itself creates and writes an
// extra (randomly-named) copy of each screenshot into when storeScreenshots
// is true. We don't use noInlineScreenshots to ever read those copies back,
// so storeScreenshots stays false to avoid that pointless extra churn on
// top of the real per-project screenshot files hooks.ts already writes.
const screenshotsDirectory = path.join(env('SCREENSHOT_PATH'), projectName)

const options: Options = {
    theme: 'bootstrap',
    jsonFile: env('JSON_REPORT_FILE'),
    output: env('HTML_REPORT_FILE'),
    screenshotsDirectory,
    storeScreenshots: false,
    reportSuiteAsScenarios: true,
    launchReport: false,
    name: projectName,
    brandTitle: `${projectName} - ${today}`,
    metadata: {
        'Environment': env('UI_AUTOMATION_HOST', '-'),
        'Target URL': resolveTargetUrl(),
    },
}

reporter.generate(options)