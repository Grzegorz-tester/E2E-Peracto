# INSINKERATOR_EU_ADMIN automation notes

Peracto Admin for the InSinkErator EU storefront. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` only.

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/INSINKERATOR_EU_ADMIN_STAGING.env` -> `https://staging-peracto.insinkerator-eu.work` (staging, free rein). Host live-verified when scaffolded (2026-08-25).
- No production or release env.

## Test accounts and data
- User type (`users.json`): `admin`.
- Creds: `INSINKERATOR_EU_ADMIN_ADMIN_EMAIL` / `INSINKERATOR_EU_ADMIN_ADMIN_PASSWORD` (`PROJECT=insinkerator_eu_admin`). Currently COMMENTED OUT in `.env` (2026-10-22): the account returns "Insufficient role" on this environment. With them disabled the run falls back to the generic `ADMIN_EMAIL`/`ADMIN_PASSWORD`, which is not known to work here either.
- Fixing this needs an account with sufficient role from the client/AM side, not a test change.

## Known site defects (expected red)
- None recorded; the tenant has effectively never had a live-verified run (access blocked since at least 2026-09-10).

## Quirks and gotchas (tenant-specific)
- Config gaps found by audit, filled from other tenants' values and only dry-run verified:
  - 5 `common.json` keys were missing (2026-09-10): `success toast`, `Back to list`, `Page Name`, `Article Heading`, `Save content`.
  - `Create New Page` / `Create New Article` keys and the whole `orphaned-pages.json` (2026-09-10).
  - `task name link` / `play button` mappings (2026-09-10).
- Uses Carbon Admin's dropdown-save convention (`Content Name`, `Open save menu`), not MIPA's; the added keys assume the same.
- Once a working account exists, live-verify all of the above before trusting failures or passes.

## Coverage and gaps
- Shared suite wired up, but effectively unverified on the real site because of the "Insufficient role" account.

## Tips for extending
- First job when creds arrive: login smoke, then a full run, checking the audited selectors above.
- Don't add EU-only scenarios to the shared folder; use a tenant folder and `scripts/check-duplicate-admin-features.sh`.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
