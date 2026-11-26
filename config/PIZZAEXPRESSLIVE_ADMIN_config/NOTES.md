# PIZZAEXPRESSLIVE_ADMIN automation notes

Peracto Admin back office for PizzaExpress Live. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` plus its own `PIZZAEXPRESSLIVE_ADMIN_features/` (added to `FEATURE_PATH` 2026-11-14 for PE-76). Storefront is a separate, production-only project (`config/PIZZAEXPRESSLIVE_config/NOTES.md`).

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/PIZZAEXPRESSLIVE_ADMIN_STAGING.env` -> `https://staging-peracto.pizzaexpresslive.pub` (staging, CRUD OK). `SCRIPT_TIMEOUT=35000`, no `EXCLUDE_TAGS`.
- No release or production admin env (as of 2026-10-24). Host was live-verified as Peracto Admin when scaffolded (2026-08-25).

## Test accounts and data
- User type (`users.json`): `admin`, reading `PIZZAEXPRESSLIVE_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (`PROJECT=pizzaexpresslive_admin`). Restored to `.env` and login-checked OK on 2026-10-22.
- Fixture: "Ivo Neame Trio" is a DRAFT event (product id 1898 on 2026-11-14) used by the PE-76 event-save scenarios, so nothing changes on the storefront. Each scenario restores what it changes.
- Staging data (2026-11-14, via the API): 0 orders, 0 promotions, 0 addresses, 0 shipping services, 0 categories, 0 locations; 1880 products, 3576 variants (all draft), 23 users. Orders are expected to stay at 0 on every environment: Peracto holds no orders for this tenant, all ticket sales are handled by Spektrix (confirmed by the user 2026-11-19). So order export, order detail/tax, Create Order and the PE-76 order scenarios (ORD-02..04, DB-04/05) are NOT APPLICABLE here, not blocked; the shared suite's Orders tab only proves the empty list renders. Export Order Data with 0 orders does nothing at all (no download, no request).

## Tenant differences
- Config gaps filled 2026-09-10 when content-creation was promoted: "Create New Page"/"Create New Article" keys and the whole `orphaned-pages.json` (copied from Carbon Admin).
- `pages.json` has no `content-page-new`/`content-article-new` page ids (HIB_ADMIN and KEYLITE_ADMIN do). If a shared scenario starts asserting on those pages, copy them from another tenant.
- An orphaned tenant-specific copy of content-creation/tasks/product-management existed here but never ran; removed in the 2026-09-10 duplicate cleanup.

## Known site defects (expected red)
- Content save: the "Open save menu" dropdown never opens on PizzaExpressLive staging (CONFIRMED live, recorded in `content-creation.feature`; date of last check not recorded, around 2026-08-31). A failure on "Save content" in content-creation is expected until fixed, not a selector gap. Re-verify live before relying on this.

## PE-76 (Peracto 79 / Symfony 7.4 / PHP 8.4) findings, 2026-11-14
- `pe76-admin-writes.feature` (tag `@PE-76`): logout ends the session (incl. back button), Settings > Utilities > Key Category Label save/restore, new user role change + Disabled status then delete, draft event attribute (Pre Title) save/restore, child event price 19.99 round-trip/restore. 5/5 passing on staging.
- `pe76-api-auth.feature` (tag `@PE-76`, API-level, needs `API_BASE_URL` in the env): AUTH-02 refresh_token + bearer cookies are HttpOnly/Secure/SameSite=None; AUTH-03 cookie-only refresh returns 200 and rotates the token; AUTH-04 a used refresh token replayed in the body returns 401. 3/3 passing 2026-11-14. If PE-76 deliberately changes SameSite, update the expected value.
- Auth storage: the admin keeps `token`, `refresh_token`, `expires_at` in localStorage and sets no cookies. The API's `/auth` already returns `bearer` and `refresh_token` cookies (HttpOnly, Secure, SameSite=None) and refresh tokens are already single-use (replay -> 401). The admin simply sends the refresh token in the body.
- CONFIRMED config gap (pre-existing, not PE-76): no `seo_title`/`seo_description` attributes exist on this tenant, yet the product page shows a Search Engine Listing Preview Edit panel; saving it toasts success but the value is sent as a stray top-level `attribute-seo_description` key and dropped. ADM-09 cannot pass as written.
- Product pages show "You've made changes to this form." on load with no edits made (baseline behaviour, noted in case it changes after the upgrade).

## Coverage and gaps
- Full shared suite only. No recorded full-run result for this tenant in the sources; treat the first run after a long gap as a discovery run and parse `reports/PIZZAEXPRESSLIVE_ADMIN_STAGING/report.json` per scenario.

## Tips for extending
- Any bespoke PizzaExpress Live admin tab gets its own file in `PIZZAEXPRESSLIVE_ADMIN_features/`, and that glob must be added to `FEATURE_PATH`.

_Last reviewed: 2026-11-14. Sources: memory notes + feature file comments._
