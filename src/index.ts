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
// --retry-tag-filter deliberately EXCLUDES @mutates-admin-data from the
// global --retry count, rather than just applying it everywhere.
// CONFIRMED (live, MIPA_ADMIN staging, 2026-09-09): several of this
// suite's edit-existing-entity scenarios follow an edit -> assert ->
// RESTORE pattern against real, shared admin data (a real Category,
// Article, etc.) - if a step AFTER the edit but BEFORE the restore fails
// (confirmed live: a transient page.reload() "net::ERR_ABORTED"), a
// automatic retry reruns the whole scenario from scratch, which
// "remembers" the ALREADY-MUTATED value as if it were the original and
// then "restores" back to that wrong value on a clean second pass -
// silently leaving real data corrupted while the run reports a pass.
// This isn't hypothetical - it happened twice in one session (an
// Article's heading left as a disposable "qa-<timestamp>" test value,
// caught only by manually spot-checking the real site afterwards, not by
// anything in the suite itself). A transient failure on one of these
// scenarios should surface as a real failure needing a human to check
// the data's actual state, not be silently smoothed over by a retry that
// makes the corruption worse. Every other scenario (list checks, filters,
// real create-then-delete flows with no shared "before" state to
// corrupt) keeps the normal retry behaviour.
const common = `${env('FEATURE_PATH', './src/features/**/*.feature')} \
                --require-module ts-node/register \
                --require ./src/step-definitions/**/**/*.ts \
                -f json:./reports/report.json \
                --format progress-bar \
                --parallel ${env('PARALLEL')} \
                --retry ${env('RETRY')} \
                --retry-tag-filter 'not @mutates-admin-data'`;

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
//
// @mutates-admin-data gets the same automatic exclusion for CLAUDE.md's
// "Staging vs production rules" on the ADMIN side specifically: a
// production admin must stay read-only (no creating/editing/deleting
// anything through it), but the shared Carbon_admin feature folder is
// reused by tenants that DO have a production admin env (e.g.
// KOOL_ADMIN_PROD.env). Tag any admin scenario that adds/edits/deletes
// real data (e.g. address-book-management.feature) with this so it can't
// run there even if picked up by a profile's tags. Each such scenario's
// own steps also independently refuse to run against
// UI_AUTOMATION_HOST=production (see admin-address-book.ts's "I require a
// staging admin" step) - this tag exclusion and that runtime guard are
// deliberately two independent layers, not one relying on the other.
//
// @requires-order-history gets the same automatic exclusion for a
// structural reason, not a flaky-content one: this scenario only passes
// if the logged-in test account already has past orders to list, but
// CLAUDE.md's own production rule forbids ever placing a real order there
// to create that history in the first place. CONFIRMED (live, Watco UK
// production, 2026-09-09): the account's order-list page renders fine
// (no error, no email-verification gate) but is genuinely empty, so
// "first order view link" never appears - not a selector/config gap.
const productionExclusion = env('UI_AUTOMATION_HOST', 'staging') === 'production'
    ? ' and not @places-real-order and not @completes-registration and not @mutates-admin-data and not @requires-order-history'
    : '';

// EXCLUDE_TAGS (set per-project in env/<Project>.env, space-separated) lets a
// single tenant opt out of specific rows/scenarios in the SHARED Carbon_admin
// suite that don't apply to it - e.g. a nav tab the shared suite's Examples
// table expects but this tenant genuinely doesn't have. Per CLAUDE.md's
// "shared boilerplate" rules: only use this when the tab is missing for SOME
// tenants, not all of them (if every tenant lacked it, the row belongs out of
// the shared Examples table entirely, not behind a per-tenant exclusion).
const customExclusion = env('EXCLUDE_TAGS', '')
    .split(/\s+/)
    .filter(Boolean)
    .map(tag => ` and not ${tag}`)
    .join('');
const tagFilter = (tag: string) => `${tag}${productionExclusion}${customExclusion}`;

const dev = `${common} --tags '${tagFilter('@dev')}'`;
const smoke = `${common} --tags '${tagFilter('@smoke')}'`;
const regression = `${common} --tags '${tagFilter('@regression')}'`;
const carbon_regression = `${common} --tags '${tagFilter('@carbon_regression')}'`;
const PizzaExpressLive_regression = `${common} --tags '${tagFilter('@PizzaExpressLive_regression')}'`;


console.log('\n🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 \n');

export {dev, smoke, regression, carbon_regression, PizzaExpressLive_regression};