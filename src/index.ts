import dotenv from 'dotenv'
import { env } from './env/parseEnv'

dotenv.config({path: env('COMMON_CONFIG_FILE', 'env/common.env')})
dotenv.config() // optional local .env (gitignored) for real login credentials

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
const common = `${env('FEATURE_PATH', './src/features/**/*.feature')} \
                --require-module ts-node/register \
                --require ./src/step-definitions/**/**/*.ts \
                -f json:./reports/report.json \
                --format progress-bar \
                --parallel ${env('PARALLEL')} \
                --retry ${env('RETRY')}`;

// Never place a real order against a live storefront (see CLAUDE.md's
// "Staging vs production rules"). Rather than relying on picking the right
// profile/tags by hand for every production run, any scenario tagged
// @places-real-order is automatically excluded from EVERY profile below
// whenever a project's env file sets UI_AUTOMATION_HOST=production - so
// forgetting to exclude it manually isn't possible. Tag order-completing
// scenarios in any project's feature files with @places-real-order to get
// this protection.
const productionExclusion = env('UI_AUTOMATION_HOST', 'staging') === 'production'
    ? ' and not @places-real-order'
    : '';
const tagFilter = (tag: string) => `${tag}${productionExclusion}`;

const dev = `${common} --tags '${tagFilter('@dev')}'`;
const smoke = `${common} --tags '${tagFilter('@smoke')}'`;
const regression = `${common} --tags '${tagFilter('@regression')}'`;
const Panelco_regression = `${common} --tags '${tagFilter('@Panelco_regression')}'`;
const Andy_Thornton_regression = `${common} --tags '${tagFilter('@Andy_Thornton_regression')}'`;
const MIPA_regression = `${common} --tags '${tagFilter('@MIPA_regression')}'`;
const carbon_regression = `${common} --tags '${tagFilter('@carbon_regression')}'`;
const PizzaExpressLive_regression = `${common} --tags '${tagFilter('@PizzaExpressLive_regression')}'`;


console.log('\n🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 \n');

export {dev, smoke, regression, Panelco_regression, Andy_Thornton_regression, MIPA_regression, carbon_regression, PizzaExpressLive_regression};