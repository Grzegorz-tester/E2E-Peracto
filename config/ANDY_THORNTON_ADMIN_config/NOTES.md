# ANDY_THORNTON_ADMIN automation notes

Andy Thornton's Peracto Admin. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` only (no tenant-specific feature folder). Storefront is a separate project: see `config/ANDY_THORNTON_config/NOTES.md`.

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/ANDY_THORNTON_ADMIN_STAGING.env` -> `staging-peracto.andythornton.pub`. Free rein (CRUD OK). `SCRIPT_TIMEOUT=20000`.
- `env/ANDY_THORNTON_ADMIN_RELEASE.env` -> `release_branch` in hosts.json, currently `at-172-peracto.andythornton.pub` (moved from AT-171 on 2026-09-15). Treated as staging. `SCRIPT_TIMEOUT=35000` after intermittent login timeouts. When the branch number bumps, update hosts.json and the env's three URLs together. This is the ADMIN release branch; AT URLs have twice been mistaken for the storefront.
- `env/ANDY_THORNTON_ADMIN_PROD.env` -> `peracto.andythornton.com`. STRICTLY READ-ONLY per the user ("remember no edits allowed"): no create, edit or delete, and no ad hoc live testing that saves anything. Only the production tag exclusion (`@mutates-admin-data` etc.) and the staging-admin guard keep writes out, so check any new or promoted shared scenario can't reach this env untagged. 83 scenarios, all read-only (navigation, list filters, login errors, fake-address password reset, CSV exports).

## Test accounts and data
- users.json type: `admin`.
- Staging and release: `PROJECT=andy_thornton_admin`. `ANDY_THORNTON_ADMIN_ADMIN_*` is commented out in .env ("Invalid credentials", 2026-10-22), so login falls back to generic `ADMIN_EMAIL`/`ADMIN_PASSWORD`. That admin user shares one user record with the storefront test account, so a storefront password change breaks admin logins too (a mid-run change failed 34 scenarios on 2026-09-30).
- Prod: `ANDY_THORNTON_ADMIN_PROD_ADMIN_EMAIL`/`_PASSWORD` (same main account as the storefront prod login).
- Fixture, staging only: promotion id 78 "Velstar Test 1% Off" (identifier `velstar-test-1-percent`, code `VELSTARTEST1`, priority 999, Active, no end date). Backs the storefront valid-promo scenario. Do not delete as a leftover. Manage Codes modal fields match by name/id, codes default to 1 use and only persist on the main form Save.
- Registration on the staging storefront leaves `qa-<ts>@velstar-test.co.uk` users here (4 as of 2026-10-20). The Users email filter needs click + type + Enter; `fill()` alone silently shows ALL users, including real staff. Any sweeper must regex-check every row before deleting.

## Known site defects (expected red)
- Staging: shipping service id 34 ("Standard Delivery", 488 postcode cost rows) returns 422 on save even unchanged (District Start/End validation from row 358). The shared "Editing a Shipping Service's name" scenario stays red here; nothing is left renamed. Confirmed 2026-09-30.
- AT-171 release (2026-09-10): saving a Category or Shipping Service showed no toast and silently discarded the edit (likely Attribute Group/Set too). Not re-verified on AT-172; recheck before assuming it still exists.

## Tenant-specific differences
- No "User Groups" tab under Users (only "All Users"), permanent per the user. `EXCLUDE_TAGS=@user-groups` on all three envs.
- Prod has no active promotions (empty under the default "Active" filter) and can't create one, so prod also excludes `@requires-active-promotions`.
- Lists paginate at 25 and Article Categories / Shipping Services run to 2 pages: the shared entity-creation delete steps filter by stored title first (fixed 2026-09-30).
- Content editor: "Save content" (`content-save`) is hidden until "Open save menu" (`content-dropdown-save`) is clicked. Looked like a different visual-builder UI at first; RETRACTED as a divergence (2026-09-10), it was the hidden dropdown plus a missing "Content Name" alias key.
- Content saves show a success toast here (unlike MIPA); "I wait for the save to complete" uses it.
- Add Product: Attribute Set options load only after typing (async react-select); SKU does not auto-fill from Product Name; "Index Product" is visible and pre-checked.
- Category Main Image has two buttons sharing `button-resources_Main-Image` ("Upload" and "Browse"); mappings scope with `:has-text('Browse')`.
- Product exports include extra trailing CSV columns (custom attributes); the prefix assertions tolerate it.
- Tasks: all 16 tasks are Inactive and triggering one (`back_in_stock`) still returns 200 (MIPA's Inactive-fails bug does not apply).
- No product-restrictions page on this tenant (confirmed 2026-09-10; stays MIPA-only).
- AT was the reference tenant for product-variant-management.feature (only cross-checked on MIPA), File Manager and products-export promotions.

## Quirks and gotchas
- A contiguous block of "Invalid credentials" failures = check the shared account's password timeline before debugging.
- Every click on this admin should be "click precisely" (shared-suite rule).

## Coverage and gaps
- Shared suite minus User Groups (staging about 118 scenarios, 117/118 on 2026-09-30 with only the shipping service 422 red).
- No tenant-specific features exist; none needed so far.

## Tips for extending
- Missing shared tab: tag its Examples row and add the tag to `EXCLUDE_TAGS` on every AT admin env.
- Before promoting a shared scenario, confirm it is tagged `@mutates-admin-data` and guarded if it writes, because prod here must stay read-only.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
