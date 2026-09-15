"use strict";

var _cucumber = require("@cucumber/cucumber");
var fs = _interopRequireWildcard(require("fs"));
var os = _interopRequireWildcard(require("os"));
var path = _interopRequireWildcard(require("path"));
var _webElementHelper = require("../../support-functions/web-element-helper");
function _getRequireWildcardCache(e) { if ("function" != typeof WeakMap) return null; var r = new WeakMap(), t = new WeakMap(); return (_getRequireWildcardCache = function (e) { return e ? t : r; })(e); }
function _interopRequireWildcard(e, r) { if (!r && e && e.__esModule) return e; if (null === e || "object" != typeof e && "function" != typeof e) return { default: e }; var t = _getRequireWildcardCache(r); if (t && t.has(e)) return t.get(e); var n = { __proto__: null }, a = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var u in e) if ("default" !== u && {}.hasOwnProperty.call(e, u)) { var i = a ? Object.getOwnPropertyDescriptor(e, u) : null; i && (i.get || i.set) ? Object.defineProperty(n, u, i) : n[u] = e[u]; } return n.default = e, t && t.set(e, n), n; }
// Generic, reusable download-capturing step - not specific to any one
// project's export page. Stores both the browser-suggested filename and a
// local path to the saved file under `variableName` (and `variableName`
// + "__path"`) in globalVariables, the same "remembered value" convention
// already used elsewhere (verify-element-value.ts's "I remember the text
// of ... as ...") rather than introducing a separate storage mechanism
// just for downloads.
(0, _cucumber.When)(/^I click on the "([^"]*)" button, remembering the downloaded file as "([^"]*)"$/, async function (elementKey, variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const [download] = await Promise.all([page.waitForEvent("download", {
    timeout: 20000
  }), page.click(elementIdentifier)]);
  const savedPath = path.join(os.tmpdir(), `${Date.now()}-${download.suggestedFilename()}`);
  await download.saveAs(savedPath);
  this.globalVariables[variableName] = download.suggestedFilename();
  this.globalVariables[`${variableName}__path`] = savedPath;
});
(0, _cucumber.Then)(/^the remembered "([^"]*)" download should be named "([^"]*)"$/, async function (variableName, expectedFilename) {
  const actual = this.globalVariables[variableName];
  if (actual !== expectedFilename) {
    throw new Error(`Expected the "${variableName}" download to be named "${expectedFilename}", but it was named "${actual}"`);
  }
});
(0, _cucumber.Then)(/^the remembered "([^"]*)" download should not be empty$/, async function (variableName) {
  const savedPath = this.globalVariables[`${variableName}__path`];
  const stats = fs.statSync(savedPath);
  if (stats.size === 0) {
    throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) to be non-empty, but it was 0 bytes`);
  }
});

// For a CSV/text export, confirms the file actually contains the expected
// shape (e.g. its header row) rather than just "some bytes" - a download
// that's non-empty but garbled (an error page saved as if it were the
// export) would still pass the "not empty" check above.
(0, _cucumber.Then)(/^the remembered "([^"]*)" download should start with the text "([^"]*)"$/, async function (variableName, expectedPrefix) {
  const savedPath = this.globalVariables[`${variableName}__path`];
  const content = fs.readFileSync(savedPath, "utf-8");
  if (!content.startsWith(expectedPrefix)) {
    throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) to start with "${expectedPrefix}", but it started with "${content.slice(0, 200)}"`);
  }
});

// Order-independent alternative to the "should start with the text" step
// above - for a CSV whose header columns are confirmed present but not
// necessarily in the same order on every tenant (e.g. per-tenant custom
// attributes interleaved with the standard ones, rather than only
// appended at the end).
(0, _cucumber.Then)(/^the remembered "([^"]*)" download's header row should contain the columns "([^"]*)"$/, async function (variableName, expectedColumns) {
  const savedPath = this.globalVariables[`${variableName}__path`];
  const content = fs.readFileSync(savedPath, "utf-8");
  const headerRow = content.split(/\r?\n/, 1)[0];
  const actualColumns = headerRow.split(",");
  const missingColumns = expectedColumns.split(",").filter(column => !actualColumns.includes(column));
  if (missingColumns.length > 0) {
    throw new Error(`Expected the "${variableName}" download (${this.globalVariables[variableName]}) header row to contain the columns "${missingColumns.join(", ")}", but the header row was "${headerRow}"`);
  }
});