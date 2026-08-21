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
const options = {
  theme: 'bootstrap',
  jsonFile: (0, _parseEnv.env)('JSON_REPORT_FILE'),
  output: (0, _parseEnv.env)('HTML_REPORT_FILE'),
  screenshotsDirectory: (0, _parseEnv.env)('SCREENSHOT_PATH'),
  storeScreenshots: true,
  reportSuiteAsScenarios: true,
  launchReport: false,
  name: projectName,
  brandTitle: `${projectName} - ${today}`
};
_cucumberHtmlReporter.default.generate(options);