# RUSSELLS_ADMIN automation notes

Russells Peracto Admin site. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` (about 120 scenarios). `src/features/RUSSELLS_ADMIN_features/` is on the `FEATURE_PATH` but empty: its earlier bespoke copies of content-creation/tasks/product-management were duplicates of the shared files and were deleted on 2026-09-10.

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/RUSSELLS_ADMIN_STAGING.env` -> `staging-peracto.russells-parts.work`. Staging: CRUD freely. `SCRIPT_TIMEOUT=35000`.
- No release or production admin env (only `staging` in `hosts.json`).
- Scaffolded 2026-08-25 in the admin coverage rollout; host live-verified as Peracto Admin before scaffolding.

## Test accounts and data
- `users.json`: `admin`. `.env`: `RUSSELLS_ADMIN_ADMIN_EMAIL/_PASSWORD` (`PROJECT=russells_admin`). Restored after the 2026-09-16 `.env` wipe and login-checked 2026-10-22.
- Not to be confused with the storefront's `RUSSELLS_WISHLIST_ADMIN_*` ("wishlist admin" storefront user).
- No tenant-specific fixtures recorded.

## Known site defects (expected red)
- None recorded for this tenant. No full regression result for Russells admin is recorded in memory notes, so there's no baseline yet.

## Tenant-specific differences
- Content save button text is "Save" (as on Indespension; MIPA/KOOL use "save"); the shared content-creation steps already handle this.
- Orphaned Pages menu has real pre-existing rows (confirmed live 2026-08-31). An earlier note claimed it was empty; that was a verification miss.
- Every task triggers successfully regardless of Active/Inactive status (confirmed live 2026-08-31).
- Task rows can attach to the DOM a moment after the table shell; a query straight after navigation can see 0 rows. The shared step already waits, but keep this in mind when debugging by hand.

## Coverage and gaps
- Shared suite only. No Russells-specific admin tabs identified.
- Needs a first full live run to establish which shared scenarios fit this tenant; verify any "tab missing" failure live (nav item absent vs selector gap) before excluding anything.

## Tips for extending
- Bespoke Russells admin coverage goes in `src/features/RUSSELLS_ADMIN_features/`; run `scripts/check-duplicate-admin-features.sh` before promoting anything to the shared folder.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
