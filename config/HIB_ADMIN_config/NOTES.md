# HIB_ADMIN automation notes

Peracto Admin back office for HIB. Runs the shared suite `src/features/CARBON_ADMIN_SHARED_features/`; staging and release also include `src/features/HIB_ADMIN_features/` (currently empty, no bespoke tabs). Storefront is a separate project (`config/HIB_config/NOTES.md`).

Shared Peracto Admin quirks: see config/CARBON_ADMIN_config/NOTES.md

**Never create real HIB orders** (CLAUDE.md). Nothing in the admin suite places orders; keep it that way.

## Environments
- `env/HIB_ADMIN_STAGING.env` -> `https://staging-peracto.hib.pub` (staging, CRUD OK). `SCRIPT_TIMEOUT=20000`. Shares `staging-api.hib.pub` with the storefront.
- `env/HIB_ADMIN_RELEASE.env` -> `https://hib-170-peracto.hib.pub` (release, CRUD OK). `SCRIPT_TIMEOUT=35000`. Release API was slow (`/locations` ~12s, logins 11.5-12.7s on 2026-09-27).
- `env/HIB_ADMIN_PROD.env` -> `https://peracto.hib.co.uk`, added 2026-10-15. Strictly READ-ONLY. `FEATURE_PATH` is the shared folder only.
- Dead host signature: `ERR_SSL_VERSION_OR_CIPHER_MISMATCH` on a `*.hib.pub` host means the subdomain no longer exists (hib-170 had a TLS outage on 2026-09-25, then recovered).

## Test accounts and data
- User type (`users.json`): `admin`.
- Credentials: staging/release (`PROJECT=hib_admin`) read `HIB_ADMIN_ADMIN_EMAIL`/`_PASSWORD`; prod (`PROJECT=hib_admin_prod`) reads `HIB_ADMIN_PROD_ADMIN_*`. Login re-verified 2026-10-22.
- The admin login account must have NO "User Group" assigned (Users > All Users > Edit > Customer > "User Group", not "Roles", not the "User Groups" nav). If one is set, both Billing and Delivery address-create scenarios fail outright (confirmed 2026-09-12). Clear it with "Clear Value".
- Fixture, do not delete: staging promotion id 2 "Velstar Test 1% Off" (identifier `velstar-test-1-percent`, code `VELSTARTEST1`, priority 999, no end date), created 2026-10-14. Backs the shared "edit a Promotion's success message" and "filter Promotions by Name" scenarios; staging had zero promotions before. The code is there on purpose so it does not auto-apply to every storefront basket.
- Storefront-supporting staging data, do not delete: article category 8 "Blog" and form 10's field links (see HIB storefront notes).
- Add User on hib-170 requires Company Name and Account Number (mapped in this tenant's `user-detail.json`, filled with "if present" steps).

## EXCLUDE_TAGS and tenant differences
- `@requires-shipping-services` excluded on all 3 envs: HIB's Shipping Services list is empty (API `totalItems` 0, confirmed 2026-09-24) and out of scope per the user (2026-09-12). The tab itself exists.
- Prod also excludes `@requires-active-promotions` (prod has 0 promotions).
- Attributes export header column order differs from other tenants (HIB custom attributes interleaved); the shared scenario uses the order-independent "header row should contain the columns" step.
- Content save dropdown has a third option, "Save and Index". Clicking only the toggle does nothing visible; it needs the second click on "Save content".
- `duck.jpg` is absent from HIB's File Manager (2026-09-11); image-picker now uploads its own fixture.

## Known site defects (expected red)
- PROD: admin Orders list is broken. `GET prod-api.hib.pub/orders` returns 500 after ~29s (even `itemsPerPage=1`) with no CORS header, so the UI spins forever. 4 Orders scenarios stay red (confirmed 2026-10-15). Account manager needs to know.
- STAGING: intermittent PHP JIT 500s on the shared API (see storefront notes). On admin it shows as "Unexpected token '<', "<!-- Warni"... is not valid JSON" on the sign-in form, and `POST /products` 500'd once. Explained 9 of 10 failures in a 108/118 run on 2026-10-15. Not test-fixable.
- RELEASE (as of 2026-09-27): Add User occasionally stuck submitting for 8-16s+ (intermittent slow backend write, not reproducible by hand); `/attribute-sets` search occasionally takes 9-10s+ (generic react-select type-to-search wait raised to 20s).
- Minor real race: clicking Reset on the forgotten-password page before the admin app finishes its startup API calls shows "An unknown error occurred" and sends nothing (6/6). Shared scenario now settles first.

## Quirks and gotchas
- Manage Variants not navigating after the Option save: three rounds of fixes (identifier auto-populates on focus so typing gave "sizesize"; async re-render needed a settle; 2026-10-15 switched to "retrying until redirected"). Still occasionally intermittent. A manual pass by the user has twice beaten an automated "confirmed bug" here.
- All Attributes, Attribute Groups/Sets and Form Fields lists paginate at 25: filter by name before deleting, and search the API before creating anything.
- Our own shared scenario damaged real data once: `editing-existing-entities.feature` failed mid-run on 2026-09-25 and left release category 25 (Cloakroom Units) renamed "qa-<timestamp>" (restored to "Bathroom Cloakroom Units"). That scenario has no clean-up on mid-way failure; check for `qa-` names after a red run.
- Leftovers to watch for: 2 "Velstar Test Content 2026-09-24 ..." attributes were left on hib-170 (as of 2026-09-24); staging test products 728-731 and category 27 were cleaned up 2026-10-15.
- A failure on a still-"Loading..." Country field happened once while hib-170 was slow; it passed on rerun.

## Coverage and gaps
- Full shared Peracto Admin suite (login, tabs, CRUD, filtering, exports, content, products/variants, users, address book). Results: release 115/118 (2026-09-27), staging 108/118 with 9 explained by API 500s (2026-10-15), prod 80/84 (4 Orders 500s, 2026-10-15).
- No bespoke HIB_ADMIN feature files; shipping services and (on prod) promotions deliberately excluded.

## Tips for extending
- If promotion scenarios fail on staging, confirm promotion 2 still exists before suspecting the tests.
- A HIB-only required field on a shared form is filled with the "... if present" steps and mapped only in this tenant's mapping file.
- When a scenario passes alone but fails in a full run, check step timings for a click landing milliseconds after navigation before calling it transient.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
