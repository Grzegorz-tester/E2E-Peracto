# JTDOVE_ADMIN automation notes

JT Dove's Peracto Admin. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` plus `src/features/JTDOVE_ADMIN_features/` (currently empty, as of 2026-10-24). Storefront is a separate project: see `config/JTDOVE_config/NOTES.md`. For quirks common to every Peracto Admin tenant, see `config/CARBON_ADMIN_config/NOTES.md`.

## Environments
- `env/JTDOVE_ADMIN_STAGING.env` -> https://staging-peracto.jtdove.pub. Free rein (create/edit/delete), `@mutates-admin-data` scenarios run.
- `env/JTDOVE_ADMIN_RELEASE.env` -> `release_branch` = https://4-4-0-peracto.jtdove.pub (added 2026-10-22). Treated as staging. The host changes per release: update `hosts.json` AND the env's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL`.
- No production admin env (as of 2026-10-24). If one is added it must be read-only.
- Both envs: `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=20000`, no `EXCLUDE_TAGS`.

## Test accounts and data
- `users.json` type `admin` -> `JTDOVE_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (same creds work on staging and 4-4-0). These were among the vars restored to `.env` on 2026-10-22 after the 2026-09-16 wipe, and login-checked OK.
- Staging promotions 15-26 (`velstar-test-*`, codes `VELSTAR*`) are storefront test fixtures created via the admin API on 2026-10-23. DO NOT DELETE or edit them. The shared "Creating a new Promotion, then deleting it" scenario only deletes the row containing its own unique title, but it does NOT filter first: with 26+ promotions on staging (since 2026-10-23) the new row may land beyond the 25-row first page. If it times out on delete, add the "Name filter" + Apply pattern used by the Category/Attribute scenarios, and clean up the leftover "Velstar Test" row (untested risk, as of 2026-10-24).
- Staging users 62 (shared storefront test account, Cash Account group) and 73 ("Velstar Test Credit", Credit Account group) back storefront scenarios: don't edit their groups/payment types from admin tests.
- Customer groups matter for payment: Cash Account = card only; Credit Account = "account" payment only.

## Known site defects (expected red)
- None specific to JTDove admin recorded (as of 2026-10-24). First release smoke on 4-4-0-peracto: 5/5 (2026-10-22).
- Suspected (storefront-visible, configured here): promotion "Limit Total Uses" isn't counted for code promotions (uses stayed 0 after a real order). Raised with QA 2026-10-23.

## Quirks and gotchas
- Admin nav matches the shared suite except there is no User Groups tab (2026-10-22 review). No `EXCLUDE_TAGS` is set, yet `common.json`/`dashboard.json` still map `nav-users-user-groups`. If the `@user-groups` rows go red, verify the tab is really absent, then add `EXCLUDE_TAGS=@user-groups` to both env files (the Andy Thornton/Lamona precedent).
- Historic (2026-08-31) claim that a non-forced "Save content" click fails on JTDove was re-tested live on 2026-09-10 and NOT reproduced: the shared non-forced click works. Don't switch to a forced click on the strength of the old finding.
- JTDove once had its own bespoke copies of `content-creation`/`tasks`/`product-management.feature` that double-ran alongside the shared ones; removed 2026-09-10. Keep `JTDOVE_ADMIN_features/` free of shared-suite filenames (`scripts/check-duplicate-admin-features.sh`).
- `tasks.json` "task name link"/"play button" mapping was missing here and filled on 2026-09-10.

## Coverage and gaps
- Covered: the whole shared Peracto Admin suite (login, tab sweeps, first-item redirects, entity create/edit/delete, content, products/variants, forms, filtering, file manager, tasks, user/address management, products export).
- No JTDove-specific admin scenarios yet. Candidates: customer group payment-type rules, promotion settings used by the storefront, ERP/Kerridge-backed data views.
- The admin API (`staging-api.jtdove.pub`, bearer token from an admin login) is how storefront fixtures were created; see storefront notes for its quirks (pence amounts, PUT not PATCH, read-only `uses`).

## Tips for extending
- Put JTDove-only admin scenarios in `src/features/JTDOVE_ADMIN_features/` (already on `FEATURE_PATH`), never in the shared folder unless every tenant has the feature.
- Tenant-specific required form fields: use the "... with a unique value if present" / "react-select if present" steps and map the testid in this project's mappings only.
- Before a full regression, run a short smoke (`@smoke`) to confirm the release host is up; release hosts are torn down between versions.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
