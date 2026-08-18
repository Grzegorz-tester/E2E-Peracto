"use strict";

var _dotenv = _interopRequireDefault(require("dotenv"));
var _fs = _interopRequireDefault(require("fs"));
var _path = _interopRequireDefault(require("path"));
var _playwright = require("playwright");
var _parseEnv = require("../env/parseEnv");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
_dotenv.default.config({
  path: (0, _parseEnv.env)('COMMON_CONFIG_FILE', 'env/common.env')
});
const scenarioStatus = element => {
  const statuses = (element.steps ?? []).map(step => step.result?.status);
  if (statuses.includes('failed')) return 'failed';
  if (statuses.length > 0 && statuses.every(status => status === 'passed')) return 'passed';
  return 'skipped';
};
const escapeHtml = value => value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const STATUS_LABEL = {
  passed: 'PASS',
  failed: 'FAIL',
  skipped: 'SKIPPED'
};
const STATUS_COLOR = {
  passed: '#1a7f37',
  failed: '#cf222e',
  skipped: '#9a6700'
};
const buildHtml = features => {
  const scenariosByFeature = features.map(feature => ({
    name: feature.name,
    // Cucumber's json formatter emits the Background as its own "element";
    // it isn't a scenario and has no pass/fail status worth listing.
    scenarios: (feature.elements ?? []).filter(el => el.keyword !== 'Background')
  }));
  const allScenarios = scenariosByFeature.flatMap(f => f.scenarios);
  const passed = allScenarios.filter(el => scenarioStatus(el) === 'passed').length;
  const failed = allScenarios.filter(el => scenarioStatus(el) === 'failed').length;
  const skipped = allScenarios.length - passed - failed;
  const featureSections = scenariosByFeature.map(_ref => {
    let {
      name,
      scenarios
    } = _ref;
    const items = scenarios.map(scenario => {
      const status = scenarioStatus(scenario);
      return `<li>${escapeHtml(scenario.name)} &mdash; <strong style="color:${STATUS_COLOR[status]}">${STATUS_LABEL[status]}</strong></li>`;
    }).join('\n');
    return `<h2>${escapeHtml(name)}</h2>\n<ul>\n${items}\n</ul>`;
  }).join('\n');
  return `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<style>
  body { font-family: Arial, Helvetica, sans-serif; padding: 32px; color: #1f2328; }
  h1 { font-size: 20px; margin-bottom: 4px; }
  .summary { color: #57606a; margin-bottom: 24px; font-size: 13px; }
  h2 { font-size: 15px; margin-top: 20px; margin-bottom: 6px; border-bottom: 1px solid #d0d7de; padding-bottom: 4px; }
  ul { margin: 0 0 12px 0; padding-left: 20px; }
  li { margin-bottom: 4px; font-size: 13px; }
</style>
</head>
<body>
<h1>Cucumber Test Report</h1>
<div class="summary">${passed} passed, ${failed} failed, ${skipped} skipped, ${allScenarios.length} total &mdash; generated ${new Date().toISOString()}</div>
${featureSections}
</body>
</html>`;
};
const run = async () => {
  const jsonReportPath = (0, _parseEnv.env)('JSON_REPORT_FILE');
  const features = JSON.parse(_fs.default.readFileSync(jsonReportPath, 'utf-8'));
  const html = buildHtml(features);
  const outputPath = (0, _parseEnv.env)('PDF_REPORT_FILE', _path.default.join(_path.default.dirname((0, _parseEnv.env)('HTML_REPORT_FILE')), 'cucumber-pdf-report.pdf'));
  const browser = await _playwright.chromium.launch();
  const page = await browser.newPage();
  await page.setContent(html, {
    waitUntil: 'load'
  });
  await page.pdf({
    path: outputPath,
    format: 'A4',
    margin: {
      top: '20px',
      bottom: '20px',
      left: '20px',
      right: '20px'
    }
  });
  await browser.close();
  console.log(`📄 Cucumber PDF report ${outputPath} generated successfully 👍`);
};
run().catch(error => {
  console.error('😞 Failed to generate PDF report:', error);
  process.exitCode = 1;
});