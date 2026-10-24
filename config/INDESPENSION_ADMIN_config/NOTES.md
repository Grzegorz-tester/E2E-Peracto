# INDESPENSION_ADMIN automation notes

Indespension's Peracto Admin. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/`. Storefront is a separate project: see `config/INDESPENSION_config/NOTES.md`.

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/INDESPENSION_ADMIN_STAGING.env` -> `staging-peracto.indespension.pub`. Free rein (CRUD OK). `FEATURE_PATH` also globs `src/features/INDESPENSION_ADMIN_features/`, which is currently empty (Test Harnesses coverage was removed, see below).
- `env/INDESPENSION_ADMIN_PROD.env` -> `peracto.indespension.co.uk`. Read-only: no create, edit or delete. Only the shared folder is in `FEATURE_PATH`; write scenarios are kept out by the production tag exclusion plus the "I require a staging admin" guard. 85/85 passed on first prod run (2026-09-29).
- Both envs: `SCRIPT_TIMEOUT=35000`, `EXCLUDE_TAGS=@requires-redirects`.
- No admin release env exists.

## Test accounts and data
- users.json type: `admin`.
- Staging: `PROJECT=indespension_admin` -> `INDESPENSION_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (restored to .env 2026-10-22, login-checked OK); falls back to generic `ADMIN_EMAIL`/`ADMIN_PASSWORD` if absent (that is what the 2026-09-29 run used).
- Prod: `PROJECT=indespension_admin_prod` -> `INDESPENSION_ADMIN_PROD_ADMIN_EMAIL`/`_PASSWORD`.
- No Velstar-owned fixtures recorded for this tenant.
- Leftovers from a failed run are `qa-*` users and `qa-`-named categories; clean them up by exact name (3 users + 1 category were removed 2026-09-29).

## Known site defects (expected red)
- None open as of 2026-09-29 (staging rerun of the affected features 25/25 after fixes).

## Tenant-specific differences
- Redirects list is genuinely empty (API `totalItems` 0, staging, 2026-09-29), so the list-filtering Redirects row is in its own `@requires-redirects` Examples block and excluded here. The prod env excludes it too (not separately verified that prod is empty). first-item-redirects accepts the empty state.
- Delete User trigger is a `<button>`, not `<a>`: `user-detail.json` uses KOOL's tag-agnostic XPath.
- Categories already hold 25+ rows and paginate at 25: the shared entity-creation Category scenario filters by Name before deleting (verified on this tenant first, 2026-09-29).
- Content save icon's SVG `data-icon` is "floppy-disk" here (vs "save" on MIPA/KOOL); already handled in mappings.
- Indespension was an independent third confirmation of product-management.feature's testids (2026-08-27) and its configs have been the clean reference copies used to repair other tenants' mappings.
- Password reset works under headless automation here (unlike some tenants with reCAPTCHA issues).

## Quirks and gotchas
- Test Harnesses: a menu group whose one page, "Carweb - Get Vehicle By VRM", calls `/test-harness/carweb-get-vehicle-by-vrm/<VRM>`. That endpoint is not deployed on the staging API (unauthenticated: 401 on real routes, 404 on this one, like a made-up route). Coverage was built then REMOVED at the user's request (2026-09-29). Don't re-add until devs deploy it and the user asks. Testids if re-adding: nav `nav-test-harnesses`, `nav-test-harnesses-carweb---get-vehicle-by-vrm`; page `vrm`, `submit`, `error-vrm`.
- Running a dry run writes over `reports/INDESPENSION_ADMIN_STAGING/` (it overwrote a real report once, 2026-09-29).

## Coverage and gaps
- Full shared suite minus Redirects filtering (about 120 scenarios on staging as of 2026-09-29).
- Bespoke tabs beyond the shared set (e.g. Test Harnesses) are uncovered by design.

## Tips for extending
- A tenant-only tab goes in `src/features/INDESPENSION_ADMIN_features/` (already in the staging `FEATURE_PATH`), never in the shared folder.
- Before promoting anything to the shared folder, run `scripts/check-duplicate-admin-features.sh`.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
