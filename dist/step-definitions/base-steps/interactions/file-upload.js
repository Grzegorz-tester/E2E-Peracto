"use strict";

var _cucumber = require("@cucumber/cucumber");
var _path = _interopRequireDefault(require("path"));
var _webElementHelper = require("../../support-functions/web-element-helper");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
// Fixture files live once under src/features/fixtures/ rather than per-project,
// so any project can reuse the same CSV/file across scenarios (e.g. a Quick
// Order CSV upload) without duplicating test data.
(0, _cucumber.When)(/^I upload the "([^"]*)" file to the "([^"]*)" input$/, async function (fixtureFile, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const filePath = _path.default.join(process.cwd(), "src/features/fixtures", fixtureFile);
  await page.setInputFiles(elementIdentifier, filePath);
});