# JTDOVE_ADMIN automation notes

JT Dove's Peracto Admin. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` plus `src/features/JTDOVE_ADMIN_features/` (currently empty, as of 2026-10-24). Storefront is a separate project: see `config/JTDOVE_config/NOTES.md`. For quirks common to every Peracto Admin tenant, see `config/CARBON_ADMIN_config/NOTES.md`.

## Environments
- `env/JTDOVE_ADMIN_STAGING.env` -> https://staging-peracto.jtdove.pub. Free rein (create/edit/delete), `@mutates-admin-data` scenarios run.
- `env/JTDOVE_ADMIN_RELEASE.env` -> `release_branch` = https://4-5-1-peracto.jtdove.pub since 2026-11-24 (was 4-4-0-peracto; added 2026-10-22; 4-5-1 login smoke 5/5). Treated as staging. The host changes per release: update `hosts.json` AND the env's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL`.
- No production admin env (as of 2026-10-24). If one is added it must be read-only.
- Both envs: `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=20000`. `EXCLUDE_TAGS=@user-groups` on both (no User Groups tab, confirmed again on 4-4-0 2026-11-23); release also excludes `@requires-redirects` (4-4-0 has no active redirects, 2026-11-23).

## Test accounts and data
- `users.json` type `admin` -> `JTDOVE_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (same creds work on staging and 4-4-0). These were among the vars restored to `.env` on 2026-10-22 after the 2026-09-16 wipe, and login-checked OK.
- Staging promotions 15-26 (`velstar-test-*`, codes `VELSTAR*`) are storefront test fixtures created via the admin API on 2026-10-23. DO NOT DELETE or edit them. The shared "Creating a new Promotion, then deleting it" scenario only deletes the row containing its own unique title, but it does NOT filter first: with 26+ promotions on staging (since 2026-10-23) the new row may land beyond the 25-row first page. If it times out on delete, add the "Name filter" + Apply pattern used by the Category/Attribute scenarios, and clean up the leftover "Velstar Test" row (untested risk, as of 2026-10-24).
- Staging users 62 (shared storefront test account, Cash Account group) and 73 ("Velstar Test Credit", Credit Account group) back storefront scenarios: don't edit their groups/payment types from admin tests.
- Customer groups matter for payment: Cash Account = card only; Credit Account = "account" payment only.
- The storefront project now uses this project's admin account through the API (`users.json` "admin" with `credentialsEnvPrefix: JTDOVE_ADMIN_ADMIN`, added 2026-11-18): it reads orders it just placed, and `algolia-product-sync.feature` creates and deletes a throwaway "Velstar Test Algolia <timestamp>" product (attribute set 30) and triggers the Product Indexer task. A leftover `VELSTAR-ALG-*` product means a run died before its After-hook cleanup; delete it.

## Known site defects (expected red)
- First release smoke on 4-4-0-peracto: 5/5 (2026-10-22).
- Add Location cannot be saved, on staging AND 4-4-0 (confirmed live 2026-11-23): with every visible field filled, Save sends no request and shows no error; the console logs `Form Error: {line1: line1 is a required field}`, but the form renders no `line1` field (its address input is `address1`). Client-side schema/field mismatch, site defect. "Creating a new Location, then deleting it" is expected red until fixed; worth raising with QA/dev.
- Suspected (storefront-visible, configured here): promotion "Limit Total Uses" isn't counted for code promotions (uses stayed 0 after a real order). Raised with QA 2026-10-23.

## Quirks and gotchas
- Admin nav matches the shared suite except there is no User Groups tab (2026-10-22 review, re-confirmed 2026-11-23); excluded via `EXCLUDE_TAGS=@user-groups` on both envs.
- Required fields the shared scenarios didn't fill (fixed 2026-11-23, all "if present" so other tenants are unaffected): Add User needs Account Number (`account-number`); Location needs Status (`location-status`, "Open") AND Location Page (`location-page-status`): the latter DISPLAYS "Active" by default but still fails validation until picked explicitly. Products: there is no "Default" attribute set; the default is "Core Only", whose required "Category" attribute (`category-tags`, "Adhesives" used) otherwise 422s the save.
- Delete User is a `<button>` with an icon (not an `<a>`), so the mapping uses `normalize-space()` and accepts either tag.
- Address-book scenarios: the final "Delete User" success-toast check can be satisfied by the lingering address-delete toast, so a user delete that silently didn't happen still passed (one leftover `qa-<ts>@velstar-test.co.uk` user on each of the 2026-11-23 and 11-24 runs). Since 2026-11-24 the shared scenario also asserts the redirect to the Users list, so this should now go red instead. Leftover `qa-*` users are disposable and safe to delete.
- Historic (2026-08-31) claim that a non-forced "Save content" click fails on JTDove was re-tested live on 2026-09-10 and NOT reproduced: the shared non-forced click works. Don't switch to a forced click on the strength of the old finding.
- JTDove once had its own bespoke copies of `content-creation`/`tasks`/`product-management.feature` that double-ran alongside the shared ones; removed 2026-09-10. Keep `JTDOVE_ADMIN_features/` free of shared-suite filenames (`scripts/check-duplicate-admin-features.sh`).
- `tasks.json` "task name link"/"play button" mapping was missing here and filled on 2026-09-10.
- Tasks (2026-11-18): 15, incl. "Product Indexer" (`product_indexer`, nightly 03:00, the only way a new product reaches Algolia) and Kerridge imports. Each runs via `GET /tasks/<code>/run` on the API, the same call as the admin play button.

## Coverage and gaps
- Covered: the whole shared Peracto Admin suite (login, tab sweeps, first-item redirects, entity create/edit/delete, content, products/variants, forms, filtering, file manager, tasks, user/address management, products export).
- No JTDove-specific admin scenarios yet. Candidates: customer group payment-type rules, promotion settings used by the storefront, ERP/Kerridge-backed data views.
- The admin API (`staging-api.jtdove.pub`, bearer token from an admin login) is how storefront fixtures were created; see storefront notes for its quirks (pence amounts, PUT not PATCH, read-only `uses`).

## Tips for extending
- Put JTDove-only admin scenarios in `src/features/JTDOVE_ADMIN_features/` (already on `FEATURE_PATH`), never in the shared folder unless every tenant has the feature.
- Tenant-specific required form fields: use the "... with a unique value if present" / "react-select if present" steps and map the testid in this project's mappings only.
- Before a full regression, run a short smoke (`@smoke`) to confirm the release host is up; release hosts are torn down between versions.

_Last reviewed: 2026-11-24 (4-4-0 regression: 89/96 on 11-23, 93/94 on 11-24 with only the Location site defect red). Sources: memory notes + feature file comments._
