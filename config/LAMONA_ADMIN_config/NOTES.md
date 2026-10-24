# LAMONA_ADMIN automation notes

Lamona (spares) Peracto Admin, admin-only project: there is no Lamona storefront project (per user, "admin release branch for the time being", 2026-09-16). Runs only the shared suite `src/features/CARBON_ADMIN_SHARED_features/`; there is no `LAMONA_ADMIN_features/` folder. For quirks common to every Peracto Admin tenant, see `config/CARBON_ADMIN_config/NOTES.md`.

## Environments
- `env/LAMONA_ADMIN_RELEASE.env` -> `release_branch` = https://2-8-0-peracto.lamonasparescouk.pub (Peracto 2-8-0). Treated as staging: CRUD allowed.
- No staging or production host known (as of 2026-09-18); add a `staging` entry to `hosts.json` and a `_STAGING` env when one exists.
- `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=20000`.
- `EXCLUDE_TAGS=@user-groups @product-variants @requires-product-export`.
- The project name is "Lamona" (user confirmed), not "LamonaSpares"/"LamonaSparesCouk".

## Test accounts and data
- `users.json` type `admin` -> `LAMONA_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (a distinct tenant account, not the generic `ADMIN_*` fallback).
- Article id 49, "Velstar Test Article - regression fixture, do not delete" (unpublished, `published-at` blank), seeded 2026-09-17 with user approval because Lamona had zero articles. DO NOT DELETE: the shared "edit an existing Article's heading" scenario goes red without it.
- Default Attribute Set for product creation is "Spare Parts" (`product-detail.json` "Default Attribute Set Name"), since no "Default" set exists. Other sets: "TEST set" and several "Attribute Set <random-id>". Unconfirmed which set the real catalogue will use; revisit once real products exist.
- The 2026-09-16 `.env` wipe happened while adding the Lamona creds: append to `.env`, never overwrite it.

## Known site defects (expected red)
- None recorded. Last confirmed full run: 80/80 passing (2026-09-18).

## Quirks and gotchas
- Tenant-specific features, each confirmed by a live DOM/testid dump (don't re-litigate):
  - No "Product Variants" nav tab, and product variants are switched off entirely (Product Type offers only "Standard", no options/variants section) -> `@product-variants`.
  - No "User Groups" tab -> `@user-groups`.
  - No "Export Product Data" link on All Products -> `@requires-product-export`.
- Content editor Save button has no `data-testid` on this build: `common.json` overrides "Save content" to `button[title='Save']`.
- Mappings were copied verbatim from `CARBON_ADMIN_config` (the canonical boilerplate), deliberately not from a more customised tenant, to avoid importing version-specific fixes (e.g. KOOL's `<button>` Delete User XPath).
- Before the variants exclusion, `product-variant-management.feature` failed after creating its product but before cleanup, orphaning "Velstar Test Product ..." rows (3 deleted 2026-09-17). If any shared scenario fails mid-way, check for leftover "Velstar Test" rows.
- False alarms seen, not site regressions:
  - 2026-09-16: 3 login timeouts (20000ms) from local memory pressure while another suite ran; isolated rerun passed.
  - 2026-09-18 overnight run "36/80 failed": one `net::ERR_NETWORK_IO_SUSPENDED` (machine network dropped) followed by a wall of generic timeouts. Check for that signature before triaging failures one by one.
  - 2026-09-16 "81/81 passing" was misreported from a log tail that hid 2 real failures: always check `reports/LAMONA_ADMIN_RELEASE/report.json`.

## Coverage and gaps
- 80 applicable scenarios as of 2026-09-18 (shared suite minus the 3 excluded tags); the shared suite has grown since (a 2026-10-20 dry run listed 106 Lamona scenarios), so newer shared scenarios are not yet live-verified here.
- Not covered: anything Lamona-specific (no bespoke features), storefront (no project).

## Tips for extending
- Lamona-only admin scenarios would need a new `src/features/LAMONA_ADMIN_features/` folder added to `FEATURE_PATH` alongside the shared glob.
- When the release version bumps, update `hosts.json` and the env's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL`.
- Re-run only failing scenarios by line: `FEATURE_PATH="...feature:75:77"`.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
