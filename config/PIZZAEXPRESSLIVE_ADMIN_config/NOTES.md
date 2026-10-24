# PIZZAEXPRESSLIVE_ADMIN automation notes

Peracto Admin back office for PizzaExpress Live. Runs only the shared suite `src/features/CARBON_ADMIN_SHARED_features/` (the empty `PIZZAEXPRESSLIVE_ADMIN_features/` folder is not in `FEATURE_PATH`). Storefront is a separate, production-only project (`config/PIZZAEXPRESSLIVE_config/NOTES.md`).

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/PIZZAEXPRESSLIVE_ADMIN_STAGING.env` -> `https://staging-peracto.pizzaexpresslive.pub` (staging, CRUD OK). `SCRIPT_TIMEOUT=35000`, no `EXCLUDE_TAGS`.
- No release or production admin env (as of 2026-10-24). Host was live-verified as Peracto Admin when scaffolded (2026-08-25).

## Test accounts and data
- User type (`users.json`): `admin`, reading `PIZZAEXPRESSLIVE_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (`PROJECT=pizzaexpresslive_admin`). Restored to `.env` and login-checked OK on 2026-10-22.
- No tenant fixtures recorded (no test promotion or seeded records known).

## Tenant differences
- Config gaps filled 2026-09-10 when content-creation was promoted: "Create New Page"/"Create New Article" keys and the whole `orphaned-pages.json` (copied from Carbon Admin).
- `pages.json` has no `content-page-new`/`content-article-new` page ids (HIB_ADMIN and KEYLITE_ADMIN do). If a shared scenario starts asserting on those pages, copy them from another tenant.
- An orphaned tenant-specific copy of content-creation/tasks/product-management existed here but never ran; removed in the 2026-09-10 duplicate cleanup.

## Known site defects (expected red)
- Content save: the "Open save menu" dropdown never opens on PizzaExpressLive staging (CONFIRMED live, recorded in `content-creation.feature`; date of last check not recorded, around 2026-08-31). A failure on "Save content" in content-creation is expected until fixed, not a selector gap. Re-verify live before relying on this.

## Coverage and gaps
- Full shared suite only. No recorded full-run result for this tenant in the sources; treat the first run after a long gap as a discovery run and parse `reports/PIZZAEXPRESSLIVE_ADMIN_STAGING/report.json` per scenario.

## Tips for extending
- Any bespoke PizzaExpress Live admin tab gets its own file in `PIZZAEXPRESSLIVE_ADMIN_features/`, and that glob must be added to `FEATURE_PATH`.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
