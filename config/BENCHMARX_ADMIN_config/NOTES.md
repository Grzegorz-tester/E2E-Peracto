# BENCHMARX_ADMIN automation notes

Benchmarx's Peracto Admin. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` plus `src/features/BENCHMARX_ADMIN_features/` (`peracto-upgrade.feature`, added 2026-11-19 for BEN-233). Config copied from `JTDOVE_ADMIN_config` on 2026-10-24. Storefront is a separate project: see `config/BENCHMARX_config/NOTES.md`. For quirks common to every Peracto Admin tenant, see `config/CARBON_ADMIN_config/NOTES.md`.

## Environments
- `env/BENCHMARX_ADMIN_STAGING.env` -> https://staging-peracto.benchmarx.pub. Free rein (create/edit/delete), `@mutates-admin-data` scenarios run.
- No release or production admin env (as of 2026-10-24). If a production one is added it must be read-only.
- `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=20000`, `EXCLUDE_TAGS=@user-groups @product-variants @requires-product-export @requires-shipping-services @requires-active-promotions @requires-orders @requires-location-identifier` (98 of 115 shared scenarios run; each exclusion confirmed live on 2026-10-24, see below).

## Test accounts and data
- `users.json` type `admin`. No `BENCHMARX_ADMIN_ADMIN_*` vars: it falls back to the generic `ADMIN_EMAIL`/`ADMIN_PASSWORD` in `.env`, which the user confirmed is the Benchmarx account (2026-10-24). Add project-specific vars if that ever diverges.

## Known site defects (expected red)
- First full run (2026-10-24) also had both logging-in failure scenarios time out at 20s; they passed on the rerun, so treat a repeat as staging slowness first.
- Element `sticky_bar` (id 593, first in the Elements list) can't be saved at all, even unchanged: PUT /contents/593 returns 422 "Slug should only contain numbers, hyphens and lowercase letters". It's a staging data problem (its stored slug fails current validation), so `editing-content.feature` "Editing an existing Element's name" is red. Don't "fix" the slug without checking with the dev team: the storefront may look the element up by it (2026-10-24).

## Quirks and gotchas
- No User Groups tab and no Product Variants tab: confirmed live on 2026-10-24 (the Users menu only has All Users; Products has All Products, Categories, Attributes). Hence `EXCLUDE_TAGS`, same as Lamona.
- No checkout on Benchmarx, so Orders, Promotions and Shipping Services lists are empty on staging: filter/edit scenarios that need an existing row are excluded (`@requires-orders` added 2026-10-24 to the shared order-filtering Outline, `@requires-active-promotions` added to the shared promotion edit). Create/delete scenarios for promotions and shipping services still run and pass.
- No product export: Products has "Bulk Manage Data" instead of "Export Product Data", hence `@requires-product-export` (Lamona precedent).
- Locations are real branches with a bespoke form: name input has no testid (`input[name='name']`), no Identifier/Alias, plus Acuity `calendarId` and branch-feature checkboxes. Edit-name runs (on the first branch, restored afterwards); create/delete is excluded via `@requires-location-identifier` (added to the shared scenario 2026-10-24). Never change a branch's `calendarId`: the storefront booking form uses it.
- The content editor is an older build: Save is `button[title='Save']` (no testid, no save menu), mapped as "Save content" in `common.json`.
- Config was copied from JTDove admin: if a shared scenario fails on a selector, check this project's mappings weren't carrying a JTDove-specific value before blaming the site.

## Coverage and gaps
- Qase BEN-110 (content page), BEN-111 (image via file manager), BEN-112 (navigation item), BEN-113 (product create), BEN-114 (data presence) and BEN-115 (tasks) map onto the shared `content-creation`, `image-picker`/`file-manager`, `navigation-menu-items`, `product-management`, `tabs-contain-expected-data`/`first-item-redirects` and `tasks` features.
- User Generated Content (nav "All User Generated Content" -> `/kitchens`, page IDs `kitchens`/`kitchen-detail`) feeds the storefront's /customer-kitchens gallery. Covered by `peracto-upgrade.feature` since 2026-11-19 (list, SKU filter, detail with its "You may also like" relations). Its Categories and Attributes nav items point at the same `/categories` and `/attributes` routes as Products.
- Gap: each of BEN-110/112/113 also asks to verify the result on the storefront. The framework runs one host per project, so that cross-site check isn't automated yet. The QA case says "CKFinder"; the shared suite drives Peracto's File Manager image picker, so confirm it's the same thing.

## Tips for extending
- Put Benchmarx-only admin scenarios in `src/features/BENCHMARX_ADMIN_features/` (already on `FEATURE_PATH`), never in the shared folder unless every tenant has the feature.

## BEN-233 Peracto upgrade (API 71.3.0 -> 73 -> 81, Admin 12.1.0 -> v12.40), 2026-11-19
- `peracto-upgrade.feature` covers what the shared suite doesn't: data floors at 1000 per page with no failed API call (Products 133, Pages 355, Articles 31, Locations 139, UGC 35, staging counts on 2026-11-19: raise them if content grows), a user saved with a plus-addressed email and +44 phone/mobile, Article Category locale saved and reopened, User Generated Content list/filter/detail.
- Already covered by the shared suite: page search (list-filtering Pages by Name, PER3-156), article heading search (Articles by Heading, PER3-167), task triggering incl. the indexer (tasks.feature). Not coverable: order export filter (PER3-146), no orders on staging.
- Written assuming the upgrade is on staging (release host unknown at the time); nothing on the API root or admin bundle shows a version.
- CONFIRMED 2026-11-19: Pages at "1000 per page" requests itemsPerPage=1000, gets 200 rows back, and disables Next, so 155 of 355 pages can't be reached from that view (the API caps a page at 200; the admin doesn't know). Expected red.
- The Edit User page shows saved details as a summary card: click "Edit user details" before reading the inputs.
- Full staging run 2026-11-20: admin 104/106 (only the Pages cap above and the known sticky_bar Element), storefront 184/216 (30 CookieYes registered-URL console warnings, now on staging too; SKU search and stale Eton links known). No upgrade regressions found.
- Ad hoc reruns: use `npx cucumber-js` with `JSON_REPORT_FILE=./reports/BENCHMARX_ADMIN_ADHOC/report.json`, not `run_tests.sh`, or the main report's PDF is deleted.

_Last reviewed: 2026-11-19._
