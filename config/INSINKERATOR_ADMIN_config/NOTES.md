# INSINKERATOR_ADMIN automation notes

Peracto Admin for the InSinkErator UK storefront. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/`; no tenant-specific scenarios.

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/INSINKERATOR_ADMIN_STAGING.env` -> `https://staging-peracto.insinkerator.work` (staging, free rein, `@mutates-admin-data` runs). Host live-verified when scaffolded (2026-08-25).
- `env/INSINKERATOR_ADMIN_PROD.env` -> `https://peracto.insinkerator.co.uk/` (production: strictly read-only, write scenarios excluded and guarded).
- Staging `FEATURE_PATH` also globs `src/features/INSINKERATOR_ADMIN_features/**`, which is an empty folder (its duplicate bespoke copies were deleted in the 2026-09-10 cleanup). Harmless; add tenant-only scenarios there if ever needed.

## Test accounts and data
- User type (`users.json`): `admin`.
- Staging creds: `INSINKERATOR_ADMIN_ADMIN_EMAIL` / `INSINKERATOR_ADMIN_ADMIN_PASSWORD` (`PROJECT=insinkerator_admin`). Restored 2026-10-22 after the `.env` wipe and login-checked OK.
- Prod env uses `PROJECT=insinkerator_admin_prod`, so it reads `INSINKERATOR_ADMIN_PROD_ADMIN_*` (not set as of 2026-10-24) and then falls back to the generic `ADMIN_EMAIL`/`ADMIN_PASSWORD`, NOT the staging tenant creds. This also departs from the naming rule (PROJECT without env suffix); confirm which account prod should use before relying on it.
- Staging fixtures, seeded 2026-11-10 because these lists were empty and their edit/filter scenarios had no row to open. Do not delete:
  - Location "Velstar Test Location" (identifier/alias `velstar-test-location`) - backs "Editing a Location's name".
  - Element "Velstar Test Element" - backs "Editing an existing Element's name".
  - Redirect `/velstar-test-redirect` -> `/` - backs the Redirects From Path filter.
  - Product "Velstar Test Variant Product" (SKU `VELSTAR-TEST-VARIANT-PARENT`) with one Size=Large variant (SKU `VELSTAR-TEST-VARIANT`) - backs the Product Variants SKU filter. `product-variant-management.feature` deletes its own variant, so without this the variants list is empty.
  - The edit scenarios rename and then restore these, so a mid-scenario failure can leave a fixture renamed; check names if one goes missing.

## Known site defects (expected red)
- Attribute Group and Attribute Set saves are rejected (confirmed live 2026-11-10 via the network response): `PUT staging-api.insinkerator.work/attribute-groups/1` (and `/attribute-sets/1`) returns 400 "The type of the "id" attribute must be "int", "string" given." The admin sends `"id": "/attribute-groups/1"` (an IRI string). No error toast is shown, so the test only sees the success toast missing. Same defect as Keylite admin 2-0-1. Both "Editing an Attribute Group/Set's name" scenarios are expected red until a dev fix.

## Quirks and gotchas (tenant-specific)
- Tasks: every task triggers successfully regardless of Active/Inactive status (confirmed 2026-08-31), unlike MIPA.
- Direct deep-link to `/tasks` renders an empty list (SPA not hydrating on fresh load; Insinkerator and Carbon, 2026-08-31). Always reach it via the sidebar.
- The "trigger every task" step needed a 120000ms step timeout; first seen here (12 rows exceeded the 20000ms `SCRIPT_TIMEOUT`, 2026-08-31).
- The storefront's WAF also blocks the runner on staging and prod; if an admin run starts showing "BLOCKED BY SITE FIREWALL", the same allowlisting-via-AM fix applies (not yet seen on admin in the sources).

- Staging is very slow at times (2026-11-10): login page timing out at 60s, lists such as Locations and Variants showing the spinner for 30s+ before "No results". A batch of login timeouts or retried passes in one run is the server, not the tests.
- File Manager (CKFinder) opens on a tenant-specific "3D Models" resource type that only accepts `.glb`, so `.txt`/`.png` uploads failed "0 of 1" (confirmed live 2026-11-11; looked like slowness for two runs). `file-manager.ts` now switches to "Files" when the File Manager opens on anything other than Files/Images.
- The new-Element editor route `/content/edit/element/` needed its own `content-element-new` entry in pages.json (added 2026-11-10); `elements.json` now maps "Create New Element".

## Coverage and gaps
- Full shared Peracto Admin suite, no exclusions recorded for this tenant.
- 2026-11-10 full regression: 109/120. 4 empty-list failures fixed by seeding (all 4 then passed first time), 2 are the attribute save defect above; the rest were staging slowness (login timeouts).
- 2026-11-11 full regression on a healthy server: 114/120, no retries. 3 File Manager/image-picker failures were the 3D Models folder (fixed), 1 Article Category delete was a list re-render race (fixed with a retrying tick in `content-admin.ts`); all 5 then passed first time here and on CARBON_ADMIN staging. Only the 2 attribute save defects remain red.

## Tips for extending
- Run `scripts/check-duplicate-admin-features.sh` before adding anything to `INSINKERATOR_ADMIN_features/`; this tenant previously double-ran duplicated scenarios.

_Last reviewed: 2026-11-10. Sources: memory notes + feature file comments._
