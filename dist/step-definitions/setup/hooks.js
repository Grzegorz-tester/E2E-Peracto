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
(0, _cucumber.BeforeStep)(async function (scenario) {
  console.log(`🥒 Running cucumber step: "${scenario.pickleStep.text}"`);
});
(0, _cucumber.Before)(async function (scenario) {
  const scenarioName = sanitize(scenario.pickle.name);
  console.log(`🥒 Running cucumber "${scenario.pickle.name}"`);

  // Ensure the video directory exists
  const videoDir = _path.default.join((0, _parseEnv.env)('VIDEO_PATH'), scenarioName);
  if (!_fs.default.existsSync(videoDir)) {
    _fs.default.mkdirSync(videoDir, {
      recursive: true
    });
  }
  const contextOptions = {
    recordVideo: {
      dir: videoDir
    }
  };
  try {
    const ready = await this.init(contextOptions);
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
      const screenshotDir = (0, _parseEnv.env)('SCREENSHOT_PATH');
      if (!_fs.default.existsSync(screenshotDir)) {
        _fs.default.mkdirSync(screenshotDir, {
          recursive: true
        });
      }
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