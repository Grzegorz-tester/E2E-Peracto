"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.smoke = exports.regression = exports.dev = exports.carbon_regression = exports.PizzaExpressLive_regression = exports.MIPA_regression = exports.Andy_Thornton_regression = void 0;
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

// Never place a real order against a live storefront (see CLAUDE.md's
// "Staging vs production rules"). Rather than relying on picking the right
// profile/tags by hand for every production run, any scenario tagged
// @places-real-order is automatically excluded from EVERY profile below
// whenever a project's env file sets UI_AUTOMATION_HOST=production - so
// forgetting to exclude it manually isn't possible. Tag order-completing
// scenarios in any project's feature files with @places-real-order to get
// this protection.
//
// @completes-registration gets the same automatic exclusion, for a
// different reason: production sites commonly run real bot-protection
// (reCAPTCHA, Cloudflare, etc.) on their registration form that staging
// doesn't have - confirmed live on Watco's production registration
// (2026-08-26, "The form ReCaptcha has failed") and already known for
// PizzaExpressLive's Cloudflare-protected flows. A scenario that actually
// completes a new-account registration will therefore fail on production
// every single time regardless of what was deployed, which is pure noise
// in a post-deployment run - not a real regression signal. Tag any
// scenario whose whole point is finishing registration (not just
// exercising the form's validation, which doesn't reach the bot-check)
// with @completes-registration.
const productionExclusion = (0, _parseEnv.env)('UI_AUTOMATION_HOST', 'staging') === 'production' ? ' and not @places-real-order and not @completes-registration' : '';
const tagFilter = tag => `${tag}${productionExclusion}`;
const dev = exports.dev = `${common} --tags '${tagFilter('@dev')}'`;
const smoke = exports.smoke = `${common} --tags '${tagFilter('@smoke')}'`;
const regression = exports.regression = `${common} --tags '${tagFilter('@regression')}'`;
const Andy_Thornton_regression = exports.Andy_Thornton_regression = `${common} --tags '${tagFilter('@Andy_Thornton_regression')}'`;
const MIPA_regression = exports.MIPA_regression = `${common} --tags '${tagFilter('@MIPA_regression')}'`;
const carbon_regression = exports.carbon_regression = `${common} --tags '${tagFilter('@carbon_regression')}'`;
const PizzaExpressLive_regression = exports.PizzaExpressLive_regression = `${common} --tags '${tagFilter('@PizzaExpressLive_regression')}'`;
console.log('\n🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 \n');