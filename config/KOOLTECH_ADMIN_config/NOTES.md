# KOOLTECH_ADMIN automation notes

KOOL (Kooltech) Peracto Admin site. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/` (about 120 scenarios on staging/release, 86 on prod after unsafe tags are filtered). `src/features/KOOLTECH_ADMIN_features/` is on the staging/release `FEATURE_PATH` but currently empty. Renamed from KOOL_ADMIN on 2026-10-19.

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

## Environments
- `env/KOOLTECH_ADMIN_STAGING.env` -> `staging-peracto.kooltech.pub`. Staging: create/edit/delete freely. `SCRIPT_TIMEOUT=60000`.
- `env/KOOLTECH_ADMIN_RELEASE.env` -> `2-19-0-peracto.kooltech.pub` (added 2026-09-15). Treated as staging (CRUD OK). Same version as the storefront release but a different subdomain. On a version bump, update `hosts.json` AND the env's three URL literals. `SCRIPT_TIMEOUT=60000`.
- `env/KOOLTECH_ADMIN_PROD.env` -> `peracto.kooltech.co.uk`. Production admin: strictly read-only. `FEATURE_PATH` is the shared folder only; write scenarios are filtered and runtime-guarded. `SCRIPT_TIMEOUT=20000`.
- Before any KOOL admin run, double-check `UI_AUTOMATION_HOST` resolves where you expect: the KOOL production orders incident (2026-09-11, see `config/KOOLTECH_config/NOTES.md`) showed how easily work lands on the wrong KOOL target. Real orders from that incident are visible in the prod admin Orders list; don't touch them without the account manager.

## Test accounts and data
- `users.json`: one user type, `admin`.
- `.env` names: `KOOLTECH_ADMIN_ADMIN_EMAIL/_PASSWORD` (staging + release, `PROJECT=kooltech_admin`), `KOOLTECH_ADMIN_PROD_ADMIN_EMAIL/_PASSWORD` (prod, `PROJECT=kooltech_admin_prod`). Restored after the 2026-09-16 `.env` wipe and login-checked 2026-10-22.
- Disposable `qa-*` users are created by user-management / address-book-management; 8 orphans were cleaned on release 2026-09-15. Failed runs can leave more.
- Leftover "Velstar Test Content <timestamp>" Attribute Groups/Sets from failed runs are safe to delete (2 cleaned 2026-09-28).

## Known site defects (expected red)
- None tenant-specific currently recorded. Last full release run (2026-09-28) was 118/120, both failures fixed the same day (pagination, below). The first release run (2026-09-15) went 89/94 to 94/94 after the fixes below.

## Tenant-specific differences
- **Delete User / Reset Password triggers are `<button>`, not `<a>`** on 2-19-0-peracto. `mappings/user-detail.json` uses a tag-agnostic XPath with `not(@data-testid)`; the exclusion is required because the confirmation modal's own "Delete User" button has the same text (2 matches without it). Indespension later copied this; most other tenants still use the `<a>` selector. Staging may still be on the older `<a>` markup, which the XPath also matches.
- **Default Attribute Set has three extra required Yes/No attributes**: "Ugly Freight", "Searchable in Storefront", "Searchable in Quote Tool". Left at "Please Select", product save silently 422s ("Option '""' is not a valid option") with no toast. Filled with the `... react-select if present` step; testids mapped only in this tenant's `mappings/product-detail.json`.
- RETRACTED (2026-09-15): that 422 was first written up as a "confirmed site bug / broken attribute set data". It was three unfilled, working fields. Lesson: a 422 naming a field usually means a control the scenario never touched.
- **Attribute pagination**: 30 Attribute Groups and 61 Attribute Sets, 25 rows per page, so newly created rows aren't on page 1. Shared entity-creation.feature now filters by name, then settles, before deleting. The Category delete is still unfiltered: fix it the same way if categories exceed 25.
- Redirects has real data here (first-item-redirects exercises a real row).
- Admin forgotten-password form is not reCAPTCHA-protected (unlike Carbon Admin), so the reset scenario can run.
- Content save control label is "save" (as on MIPA); shared content-creation already handles the variants.
- Every task triggers successfully regardless of Active/Inactive status (confirmed live 2026-08-31).
- `KOOLTECH_ADMIN_config` and `INDESPENSION_ADMIN_config` were the clean reference copies when other tenants' mappings were cleaned up (forms-management round).

## Coverage and gaps
- Everything in the shared suite. No bespoke KOOL admin features yet.
- Prod: read-only subset only (login, tabs have content, first-item redirects, filtering, exports).

## Tips for extending
- A KOOL-only admin tab or field: add a small feature under `src/features/KOOLTECH_ADMIN_features/` (already on the staging/release path; add it to the prod `FEATURE_PATH` only if read-only).
- New KOOL-only form fields belong in this tenant's mappings plus an "if present" step, not hard requirements in the shared files.
- If another tenant's release hits the Delete User timeout, check its DOM: this may be a Peracto Admin UI change rolling out per version.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
