"use strict";

var _cucumber = require("@cucumber/cucumber");
var _parseEnv = require("../../env/parseEnv");
var _fs = _interopRequireDefault(require("fs"));
var _path = _interopRequireDefault(require("path"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
// Utility: sanitize names for safe file and directory usage
function sanitize(name) {
  return name.replace(/[<>:"/\\|?*]/g, '_').replace(/ /g, '_');
}
(0, _cucumber.setDefaultTimeout)(Number((0, _parseEnv.env)('SCRIPT_TIMEOUT')));

// Same projectName derivation the reporters use, so a project's own
// failure screenshots live in their own subfolder - screenshots are keyed
// only by scenario name (see sanitize() below), so a flat shared directory
// meant two projects with an identically-named scenario (e.g. any pair of
// tenants sharing the Carbon_admin suite) silently overwrote each other's
// screenshot.
const projectName = _path.default.basename((0, _parseEnv.env)('COMMON_CONFIG_FILE', 'env/common.env'), '.env');
const screenshotDir = _path.default.join((0, _parseEnv.env)('SCREENSHOT_PATH'), projectName);
(0, _cucumber.BeforeAll)(async function () {
  // Reset this project's screenshot folder once per run, not once per
  // scenario - without this, a scenario that used to fail (and was since
  // fixed) left its old failure screenshot behind forever, since nothing
  // else ever removed a screenshot once written.
  _fs.default.rmSync(screenshotDir, {
    recursive: true,
    force: true
  });
  _fs.default.mkdirSync(screenshotDir, {
    recursive: true
  });
});
(0, _cucumber.BeforeStep)(async function (scenario) {
  console.log(`🥒 Running cucumber step: "${scenario.pickleStep.text}"`);
});
(0, _cucumber.Before)(async function (scenario) {
  console.log(`🥒 Running cucumber "${scenario.pickle.name}"`);
  try {
    const ready = await this.init();
    return ready;
  } catch (err) {
    console.error('Error during scenario setup:', err);
    throw err;
  }
});
(0, _cucumber.After)(async function (scenario) {
  const {
    screen: {
      page,
      browser
    }
  } = this;
  const scenarioStatus = scenario.result?.status;
  const scenarioName = sanitize(scenario.pickle.name);
  if (scenarioStatus === 'FAILED') {
    try {
      const screenshotPath = _path.default.join(screenshotDir, `${scenarioName}.png`);
      const screenshot = await page.screenshot({
        path: screenshotPath
      });
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