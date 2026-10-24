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
- No tenant-specific fixtures recorded.

## Known site defects (expected red)
- None tenant-specific recorded.

## Quirks and gotchas (tenant-specific)
- Tasks: every task triggers successfully regardless of Active/Inactive status (confirmed 2026-08-31), unlike MIPA.
- Direct deep-link to `/tasks` renders an empty list (SPA not hydrating on fresh load; Insinkerator and Carbon, 2026-08-31). Always reach it via the sidebar.
- The "trigger every task" step needed a 120000ms step timeout; first seen here (12 rows exceeded the 20000ms `SCRIPT_TIMEOUT`, 2026-08-31).
- The storefront's WAF also blocks the runner on staging and prod; if an admin run starts showing "BLOCKED BY SITE FIREWALL", the same allowlisting-via-AM fix applies (not yet seen on admin in the sources).

## Coverage and gaps
- Full shared Peracto Admin suite, no exclusions recorded for this tenant.
- No recent run totals recorded in the sources.

## Tips for extending
- Run `scripts/check-duplicate-admin-features.sh` before adding anything to `INSINKERATOR_ADMIN_features/`; this tenant previously double-ran duplicated scenarios.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
