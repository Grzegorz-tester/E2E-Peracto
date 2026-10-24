# MIPA_ADMIN automation notes

MIPA Paints Peracto Admin site. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` plus MIPA's bespoke `src/features/MIPA_ADMIN_features/` (about 132 scenarios). Much of the shared suite was originally built and live-verified on MIPA, then promoted (2026-09-10).

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/MIPA_ADMIN_STAGING.env` -> `staging-peracto.mipa-paints.pub`. Staging: CRUD freely. Use this for MIPA admin runs at present.
- `env/MIPA_ADMIN_RELEASE.env` -> `2-8-1-peracto.mipa-paints.pub`. DORMANT: the host is gone (TLS handshake failure, 2026-10-14). Kept unchanged until the next release host exists; then bump `hosts.json` `release_branch` AND the env's three URL literals. Treated as staging when live.
- Release databases are separate from staging (different orders, products, seeded rows), so data-dependent scenarios can behave differently per host.
- No production admin env for MIPA.
- `SCRIPT_TIMEOUT=35000`: MIPA's admin genuinely takes about 12 s to redirect after login.
- A full run is long (2 to 3 hours, mostly ERP Test Harness round trips): confirm with the user before running it end to end.

## Test accounts and data
- `users.json`: `admin`. `.env`: `MIPA_ADMIN_ADMIN_EMAIL/_PASSWORD` (`PROJECT=mipa_admin`). Restored after the 2026-09-16 `.env` wipe and login-checked 2026-10-22.
- The admin login maps to real Business Central customer number `AAA01` (used by the Get Prices harness).
- Test Harness Send Order uses Order ID 1 (generic seed order present on staging and release). Order 175 exists only on staging.
- **Fixture, do not delete:** promotion id 17 "Velstar Test 1% Off" (code `VELSTARTEST1`), created 2026-09-25 for the storefront basket scenario. See `config/MIPA_config/NOTES.md`.
- "Peracto Support" is a protected system UserAdmin: the API refuses to add addresses to it.
- Every order in staging shares the same test email, so email filtering never narrows the row count (expected).
- Seeded junk product "test may" (name and SKU) existed on release 2.8.0 as row 0; the Get Product harness picks the first numeric SKU to avoid it.

## Known site defects (expected red)
- "Default" Attribute Set (id 1) rejects every save with 422 "an Attribute references multiple AttributeGroups in AttributeSet". editing-attributes-and-config.feature stays red while Default is first in the list. Staging and 2-8-1, re-checked on staging 2026-10-01.
- Pages list first row (id 60, "Category Slug Test page") can't be saved: its stored slug contains "/". Shared editing-content Page scenario is expected red on MIPA (as of 2026-09-10).
- Templates 53 and 52 reject save ("Templates can only support a single row"). `MIPA_ADMIN_features/content-known-issues.feature` asserts the current rejection and opens template 53 directly (template 101 moved to the top and saves fine). Re-verified 2026-10-01.
- Tasks: every Inactive task 500s when triggered, Active ones succeed (MIPA-only; confirmed release 2.8.0, 2026-09-08). Shared tasks.feature asserts the ideal, so it is red on MIPA.
- Image picker: Category "Main Image" Browse > Choose closes CKFinder without populating the field (MIPA and Andy Thornton, 2026-09-09/10).
- Last full staging run in memory: 130/132 (2026-10-01); the Template failure there was a test gap, since fixed.

## Tenant-specific differences
- Add User form requires "Account Number" (mapped as "User Account Number" in this tenant only).
- One-billing-address-per-user limit, reported as a 403 "Access Denied" rather than a validation error. Delivery addresses have no limit. The shared address-book step frees and restores the borrowed billing type automatically.
- No success toast on content (Page/Article/Element) saves; the always-visible save button needs no dropdown. Shared scenarios use "I wait for the save to complete".
- Index Product checkbox behaviour on product create differs from other tenants (see shared product-management.feature).
- Bespoke tabs (only here): Product Restrictions (per-SKU/per-account table, rows have no detail link; export covered, Import deliberately not), and Test Harnesses (live calls to MIPA's Business Central ERP).
- Test Harnesses: Get Product/Prices/Invoices/Customer/Account Balance/Sales Orders are read-only. Send Order WRITES a real order to BC (unique `qa-<timestamp>` reference each time; BC's "No." field max 20 chars; duplicate reference correctly rejected). Import Payment covers only the rejection path (invalid Payment Type "CARD"), because a successful import writes an unreversible ledger record.
- Get Customer, Get Invoices, Get Account Balance and Get Sales Orders look the customer up by the admin login's email.

## Coverage and gaps
- Shared suite plus Product Restrictions, the 8 Test Harness pages and content known issues.
- Not covered: Product Restrictions import, Import Payment success path.
- Admin gotchas when creating promotions: Identifier auto-fills from Name (clear before typing); a new code only saves via the main Save, not Add Code; codes default to 1 use.

## Tips for extending
- Before promoting a MIPA_ADMIN feature to the shared folder, run `scripts/check-duplicate-admin-features.sh`.
- "Confirmed MIPA-only" findings have been overturned before (File Manager, image picker): re-verify on another tenant before keeping something bespoke.
- Distinguish broken MIPA data (Attribute Set, Page 60) from unfilled fields (KOOL's 422) before writing either up.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
