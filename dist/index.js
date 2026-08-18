"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.smoke = exports.regression = exports.dev = exports.carbon_regression = exports.Panelco_regression = exports.MIPA_regression = exports.Andy_Thornton_regression = void 0;
var _dotenv = _interopRequireDefault(require("dotenv"));
var _parseEnv = require("./env/parseEnv");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
_dotenv.default.config({
  path: (0, _parseEnv.env)('COMMON_CONFIG_FILE', 'env/common.env')
});
_dotenv.default.config(); // optional local .env (gitignored) for real login credentials

// Hosts/pages/mappings/users config is loaded per-scenario by ScenarioWorld
// (src/step-definitions/setup/world.ts) from the env vars set above, rather
// than being embedded here as JSON via --world-parameters: cucumber
// re-tokenizes the whole profile string with string-argv, which doesn't
// understand JSON's `\"` escaping and mis-splits any selector value that
// contains an escaped quote followed by a space (e.g. Insinkerator's
// `:text-is(\"Reset Password\")` mappings), corrupting the JSON.

// FEATURE_PATH (set per-project in env/<Project>.env) scopes a run to that
// project's own feature folder, so the same @smoke/@regression tags used
// across every project don't pull in every other project's scenarios too.
// Falls back to every feature file when a project doesn't set it.
const common = `${(0, _parseEnv.env)('FEATURE_PATH', './src/features/**/*.feature')} \
                --require-module ts-node/register \
                --require ./src/step-definitions/**/**/*.ts \
                -f json:./reports/report.json \
                --format progress-bar \
                --parallel ${(0, _parseEnv.env)('PARALLEL')} \
                --retry ${(0, _parseEnv.env)('RETRY')}`;
const dev = exports.dev = `${common} --tags '@dev'`;
const smoke = exports.smoke = `${common} --tags '@smoke'`;
const regression = exports.regression = `${common} --tags '@regression'`;
const Panelco_regression = exports.Panelco_regression = `${common} --tags '@Panelco_regression'`;
const Andy_Thornton_regression = exports.Andy_Thornton_regression = `${common} --tags '@Andy_Thornton_regression'`;
const MIPA_regression = exports.MIPA_regression = `${common} --tags '@MIPA_regression'`;
const carbon_regression = exports.carbon_regression = `${common} --tags '@carbon_regression'`;
console.log('\n🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 \n');