"use strict";

var _dotenv = _interopRequireDefault(require("dotenv"));
var _path = _interopRequireDefault(require("path"));
var _cucumberHtmlReporter = _interopRequireDefault(require("cucumber-html-reporter"));
var _parseEnv = require("../env/parseEnv");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
_dotenv.default.config({
  path: (0, _parseEnv.env)('COMMON_CONFIG_FILE', 'env/common.env')
});

// Derived from COMMON_CONFIG_FILE's own filename (e.g. "PizzaExpressLive"
// from env/PizzaExpressLive.env) rather than the PROJECT env var - PROJECT
// is only set by projects needing per-project credential overrides (see
// loadGlobalConfig.ts), so it's blank for several projects, while every
// run always sets COMMON_CONFIG_FILE.
const projectName = _path.default.basename((0, _parseEnv.env)('COMMON_CONFIG_FILE', 'env/common.env'), '.env');
const today = new Date().toISOString().slice(0, 10);

// Same host lookup loadGlobalConfig.ts does for the step definitions -
// surfaces the actual base URL a run targeted (e.g.
// "https://release-2-8-1.mipa-paints.pub/" for MIPA_RELEASE's
// release_branch host) in the report itself, since a release branch's URL
// gets bumped mid-sprint and the report should say which one was actually
// tested without needing to go check the env file. Falls back to '-'
// rather than throwing - purely cosmetic, shouldn't block report
// generation if the lookup ever fails.
const resolveTargetUrl = () => {
  try {
    const hostsConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('HOSTS_URL_PATH'));
    const host = (0, _parseEnv.env)('UI_AUTOMATION_HOST', 'staging');
    return hostsConfig[host] ?? '-';
  } catch {
    return '-';
  }
};

// cucumber-html-reporter embeds each failure screenshot inline as a base64
// data URI straight from the JSON's step embeddings (see hooks.ts's
// this.attach) regardless of this option - screenshotsDirectory only
// matters as a fallback location the library itself creates and writes an
// extra (randomly-named) copy of each screenshot into when storeScreenshots
// is true. We don't use noInlineScreenshots to ever read those copies back,
// so storeScreenshots stays false to avoid that pointless extra churn on
// top of the real per-project screenshot files hooks.ts already writes.
const screenshotsDirectory = _path.default.join((0, _parseEnv.env)('SCREENSHOT_PATH'), projectName);
const options = {
  theme: 'bootstrap',
  jsonFile: (0, _parseEnv.env)('JSON_REPORT_FILE'),
  output: (0, _parseEnv.env)('HTML_REPORT_FILE'),
  screenshotsDirectory,
  storeScreenshots: false,
  reportSuiteAsScenarios: true,
  launchReport: false,
  name: projectName,
  brandTitle: `${projectName} - ${today}`,
  metadata: {
    'Environment': (0, _parseEnv.env)('UI_AUTOMATION_HOST', '-'),
    'Target URL': resolveTargetUrl()
  }
};
_cucumberHtmlReporter.default.generate(options);