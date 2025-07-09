"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.ScenarioWorld = void 0;
var _playwright = _interopRequireDefault(require("playwright"));
var _parseEnv = require("../../env/parseEnv");
var _cucumber = require("@cucumber/cucumber");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
class ScenarioWorld extends _cucumber.World {
  constructor(options) {
    super(options);
    this.globalConfig = options.parameters;
    this.globalVariables = {};
  }

  /**
   * Initializes a new browser, context, and page for each scenario.
   * Closes any existing resources before starting a new session.
   */
  async init(contextOptions) {
    // Gracefully close any previously opened resources
    await this.closeScreen();
    const browser = await this.newBrowser();
    const context = await browser.newContext(contextOptions);
    const page = await context.newPage();
    this.screen = {
      browser,
      context,
      page
    };
    return this.screen;
  }

  /**
   * Helper to close any open browser, context, or page.
   */
  async closeScreen() {
    if (this.screen) {
      try {
        await this.screen.page.close();
      } catch (e) {/* ignore */}
      try {
        await this.screen.context.close();
      } catch (e) {/* ignore */}
      try {
        await this.screen.browser.close();
      } catch (e) {/* ignore */}
    }
  }

  /**
   * Launches a new browser instance based on the environment variable.
   */
  async newBrowser() {
    const automationBrowsers = ['chromium', 'firefox', 'webkit'];
    const automationBrowser = (0, _parseEnv.env)('UI_AUTOMATION_BROWSER');
    if (!automationBrowsers.includes(automationBrowser)) {
      throw new Error(`Invalid UI_AUTOMATION_BROWSER: "${automationBrowser}". Valid options are: ${automationBrowsers.join(', ')}`);
    }
    const browserType = _playwright.default[automationBrowser];
    return browserType.launch({
      headless: (0, _parseEnv.env)('HEADLESS').toLowerCase() === 'true',
      args: ['--disable-web-security', '--disable-features=IsolateOrigins,site-per-process']
    });
  }
}
exports.ScenarioWorld = ScenarioWorld;
(0, _cucumber.setWorldConstructor)(ScenarioWorld);