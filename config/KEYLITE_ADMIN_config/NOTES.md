# KEYLITE_ADMIN automation notes

Peracto Admin back office for Keylite Roof Windows. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` plus Keylite's own `src/features/KEYLITE_ADMIN_features/` (Size Finder). Storefront is a separate project (`config/KEYLITE_config/NOTES.md`).

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/KEYLITE_ADMIN_STAGING.env` -> `https://staging-peracto.keyliteroofwindows.pub/` (staging, CRUD OK).
- `env/KEYLITE_ADMIN_RELEASE.env` -> `https://2-0-1-peracto.keyliteroofwindows.pub/` (release, CRUD OK). Was temporarily rolled back to `2-0-0-peracto` from 2026-09-15 to 2026-09-27 at the user's request; now back on 2-0-1. Ask the user before moving it to another branch.
- No production admin env (as of 2026-10-24). No `EXCLUDE_TAGS`.

## Test accounts and data
- User type (`users.json`): `admin`, reading `KEYLITE_ADMIN_ADMIN_EMAIL`/`_PASSWORD` (`PROJECT=keylite_admin`). Login re-verified 2026-10-22.
- Each release branch has its own seeded database: "Invalid credentials" (not a timeout) on a new branch usually means the account/password was not seeded there, not that the creds are broken generally (seen on 2-0-0, 2026-09-15).
- The admin account's own address book ran out of a safely freeable Delivery address (11 addresses, 2026-09-14), which is why the shared address-book scenarios now use a disposable new user.
- Fixtures used by the storefront suite, do not delete: Promotion id 39 (Engineer Discount, code `20SKI2025`), Form id 13 ("Contact Query"), and the Size Finder record for serial `1100160000014`.

## Tenant differences
- Bespoke tab: Size Finder (`nav-products-size-finder`, under Products, `/size-finder`) holds real installed-window records (serial, window code, height, width). `size-finder.feature` only checks the tab opens its page (content not yet explored).
- Country option is labelled "United Kingdom Of Great Britain & Northern Ireland" (Ireland also present); other tenants say "United Kingdom". Handled by the unambiguous-prefix fallback in `form.ts` / `admin-address-book.ts`.
- Product variant form has tenant-only required fields: `navSku`, `navProductName` (client-side required) and `leadTimeGB`, `leadTimeIE` (API-required, no client validation; omitting them gives a bare 500). All four are mapped in this tenant's `product-variant-detail.json` and filled by "if present" steps.
- Only 7 attribute groups (2026-09-28), so a new row is visible unfiltered; the settle after Apply in the filtered deletes matters here.

## Known site defects (expected red)
- 2-0-1-peracto (new in 2-0-1, confirmed 2026-09-28): saving ANY existing attribute group or attribute set silently fails. `PUT /attribute-groups/1` and `PUT /attribute-sets/1` return 400 "The type of the "id" attribute must be "int", "string" given" (payload sends the IRI `"/attribute-sets/1"` as `id`). The Attribute Group/Set name scenarios in `editing-attributes-and-config.feature` stay red until fixed. Unverified since 2026-09-28.

## Quirks and gotchas
- RETRACTED: the product variant save "real backend 500" (2026-09-16) was test gaps: the 22-char generated SKU exceeded the 20-char limit (422), and Lead Time GB/IE were missing (500). Both fixed; the scenario passed on 2026-09-27.
- A missing tenant-only required field silently blocks Save with no toast or request. Check for inline "is a required field" text before suspecting a redirect race.
- Report collision history: a 2026-09-14 Keylite_ADMIN run showed "7 failed" in the terminal but 0 in the report because another project overwrote the shared `report.json`. Fixed with per-project `JSON_REPORT_FILE`; parse `reports/KEYLITE_ADMIN_<ENV>/report.json` per scenario rather than trusting a log tail.
- Diagnostic scripts once left disposable "Velstar Test Product" records (ids 89-91, cleaned up). Always delete what ad hoc scripts create.

## Coverage and gaps
- Full shared suite plus Size Finder. Results: 119/121 on 2-0-0 (2026-09-27, country label, since fixed), 117/121 on 2-0-1 (2026-09-28, attribute save 400 plus a filter-delete race of ours, since fixed).
- Gap: Size Finder content and search behaviour are not tested.

## Tips for extending
- Keylite-only fields go in this tenant's mapping files with "if present" steps, never in the shared feature files.
- When the release host moves, update `hosts.json` `release_branch` and the 3 URL literals in `env/KEYLITE_ADMIN_RELEASE.env` together, then run `logging-in.feature` first to catch the per-branch credentials gap.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
