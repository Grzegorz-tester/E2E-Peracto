# CARBON_ADMIN automation notes

Carbon Admin: the Peracto 3 "Carbon" boilerplate admin. It is the reference tenant the shared Peracto Admin suite is built and first verified on, and its `config/CARBON_ADMIN_config/` is the canonical mapping set new admin tenants are copied from. Runs `src/features/CARBON_ADMIN_SHARED_features/` plus `src/features/CARBON_ADMIN_features/` (empty since the 2026-09-10 duplicate cleanup).

## Environments
- `env/CARBON_ADMIN_STAGING.env` -> https://staging-peracto.peracto3carbon.pub. Free rein (CRUD). `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=20000`, no `EXCLUDE_TAGS`.
- `env/CARBON_ADMIN_RELEASE.env` -> https://react-19-peracto.peracto3carbon.pub (added 2026-11-25 for PER3-279, Peracto Admin v13 / React 19). Uses the SAME staging API (staging-api.peracto3carbon.pub) as staging, so it's staging data: CRUD OK, and the two envs must not run write suites at the same time.
- `hosts.json` also has `dev` (http://localhost:3001, local Peracto). No production env.

## Test accounts and data
- `users.json` type `admin` -> `CARBON_ADMIN_ADMIN_EMAIL`/`_PASSWORD`. A Velstar staff login does NOT exist on this tenant ("Username could not be found"); use the dedicated Carbon admin account in `.env`.
- The shared admin account's address book already holds many unrelated addresses (26 on 2026-08-31): address scenarios locate rows by remembered marker, never by position.
- Carbon has zero Templates (as of 2026-09-18), so Templates CRUD is unverifiable here.
- Element id 144 "Velstar Test Element (automation fixture - do not delete)" seeded 2026-11-25: Carbon had zero Elements, so editing-content.feature's Element scenario failed on both envs. Don't delete it.
- `velstar-test-redirect-import.csv` (fixtures) imports `/velstar-test-import-redirect`; peracto-upgrade.feature deletes it again. A leftover row means a failed run: delete it by hand.

## Known site defects (expected red)
- Products list first-row link (`row-0-name`) renders with a 0x0 bounding box: no real click can land on it (a dispatched click works). Carbon only; KOOL/Indespension are fine. `first-item-redirects.feature` (2026-08-19).
- Task "Cleanup old Import data" returns HTTP 500 (`GET /tasks/cleanup_old_import_data/run`), reproduced twice. `tasks.feature` stays red on that row (2026-08-31).
- Last real full-run PDF on disk is from 2026-09-21; recheck both before reporting them as still open.

## Quirks and gotchas
- Every click on this admin should be "click precisely" (non-forced); force-clicking silently does nothing here.
- Direct deep-link to `/tasks` renders an empty body (SPA doesn't hydrate); arrive via the sidebar (also seen on Insinkerator).
- Carbon's content "Save" dropdown opens and works (unlike PizzaExpressLive's identical-looking one).

## Coverage and gaps
- Everything in the shared suite (below). `entity-creation.feature`, `list-filtering.feature` and `forms-management.feature` were built and verified on Carbon first (2026-09-18), then rolled out unverified to other tenants.

## Shared Peracto Admin suite (CARBON_ADMIN_SHARED_features)
Applies to every tenant whose `FEATURE_PATH` includes the shared folder (Carbon, KOOLTECH, Indespension, MIPA, HIB, Insinkerator (+EU), Russells, JTDove, Andy Thornton, Keylite, Lamona, PizzaExpressLive, ...). Tenant notes link here.

**Before calling it a site bug or a race**
- Required fields silently block Save: one unfilled required field = no toast, no error banner, often no request, just inline "is a required field" text. Tenants add their own custom required fields (MIPA Add User "Account Number"; Keylite variant Nav SKU/Nav Product Name; KOOLTECH's three Yes/No attributes on products). Dump the form's input/select testids and diff against what the scenario fills, or read the console "Form Error: {...}" warning. Fix with `... input field with a unique value if present` / `I select the "X" option from the "Y" react-select if present`, mapped in that tenant's config only.
- A 422 naming an attribute/option is usually such an unfilled field (KOOLTECH "site bug" RETRACTED 2026-09-15); only call it tenant data corruption after checking (MIPA's "Default" Attribute Set 422 was genuinely broken data).
- An invalid email makes Save no-op silently: use `... with a unique email, remembering it as ...` (generates `qa-<ts>@velstar-test.co.uk`).
- Code/Identifier validation: Attribute Code auto-generates from Label but rejects hyphens (the unique-title timestamp has them) -> use the `... with a unique code` step. Location Identifier is blank with no auto-generation and must be globally unique. Shipping Service needs a cost row to save. Symptom each time: "(could not read text)" waiting for a toast that never comes. Check the screenshot for inline validation first.
- "Confirmed" isn't permanent: File Manager "absent on Carbon" and image-picker's "MIPA only" were both overturned on re-check. Re-verify old findings live.

**Lists, pagination and deletes**
- Lists paginate at 25 rows. Delete is list-only (checkbox -> Delete Row -> confirm) for Categories, Attributes, Attribute Groups/Sets, Promotions, Article Categories, Locations, Shipping Services.
- Filter before delete: Category, Attribute, Attribute Group/Set, Article Category and Shipping Service scenarios fill the name filter, Apply, then `I wait for the page to settle` (without the settle the tick is lost on re-render). Promotion and Location deletes are still unfiltered (Locations has no filter): fix the same way if a tenant has >25 rows.
- Unfilterable lists: Locations, User Groups, Tasks, Countries, Templates, Elements, Element Areas, Form Submissions.
- Scope row-value selectors to `td` or a link: Product Variants' filter input (`text-filter-sku`) and column (`row-N-sku`) share a suffix.
- Not CRUD-able / deliberately not covered: User Groups, Element Areas (no creation UI), Countries, Tasks, Settings (16+ tabs, almost no testids, high blast radius), Templates (unverifiable).

**react-select and forms**
- Plain `I select the "X" option from the "Y" react-select`: exact label first, else the single option starting with the text (added after Keylite renamed "United Kingdom"); throws listing options on 0 or several matches.
- Async-loading options (Attribute Set on Add Product, Orphaned Pages "Select Item"): `..., typing to search`.
- Shipping Service "Available Countries" uses a second shape (`classNamePrefix="peracto-select"`) with its own step. Address Type is a multi-select.
- Image picker: Main Image has Upload and Browse sharing one testid; scope with `:has-text('Browse')`. Category Main Image never populates after CKFinder "Choose" (universal bug, asserted). Picks existing "duck.jpg" (assumed seed data).

**Save, redirect and navigation timing**
- Success toasts are not universal (MIPA shows none for content saves; Andy Thornton does): use `I wait for the save to complete` (toast or settle, whichever first). Keep `I wait for the page to settle` for load races only.
- Reload right after a save can abort (`net::ERR_ABORTED`); the reload step retries once.
- New variant save is slow to leave `/add`: assert `the current URL should not contain "/add"`, not a loose "contains".
- `getElementLocator` resolves the page ID once, so after a redirect add `I wait for the page to settle` before asserting a page-only element.
- `dashboard.json` is the global sidebar nav; its keys are merged into every tenant's `common.json`.
- "Delete User" has no testid (`//a[text()='Delete User']`); KOOLTECH 2-19-0 renders it as `<button>`, hence its tag-agnostic XPath. "Delete Address" uses `//button[text()='Delete Address' and not(@data-testid)]`.
- Content editor Save may sit behind a save dropdown ("Open save menu" if present); Lamona's Save has no testid.

**Tags and per-tenant opt-outs**
- Every write scenario: `@mutates-admin-data` + `Given I require a staging admin for this scenario` (excluded and refused on `_PROD`). Don't promote real-write scenarios lacking both.
- `EXCLUDE_TAGS` in the tenant env (space-separated, `src/index.ts`) opts out of whole tagged Examples blocks/features. As of 2026-10-24: `@user-groups` (Andy Thornton, Lamona), `@product-variants` + `@requires-product-export` (Lamona), `@requires-redirects` (Indespension), `@requires-shipping-services` (HIB), `@requires-active-promotions` (AT and HIB prod). Use only when SOME tenants lack it, and verify absence live (nav testid dump) first.
- Tenant-only extras go in `src/features/<PROJECT>_ADMIN_features/`, never the shared folder.

**Promoting to the shared suite**
- Run `scripts/check-duplicate-admin-features.sh` first: a same-named file in a tenant folder silently double-runs real writes (6 tenants were affected until 2026-09-10). On collision, merge confirmed findings into the shared file's comments, then delete the tenant copy.
- Promote read-only and guarded `@mutates-admin-data` scenarios directly (each tenant's run surfaces gaps); hold back unguarded real writes as a separate decision.
- Copy new mapping keys/files to every tenant's `config/*_ADMIN_config/`; replace hardcoded ids (e.g. MIPA page 42) with the "first item link" pattern.
- New CRUD coverage: run it 3-4 times and parse `report.json` before trusting it.

**Known tenant-specific reds in shared files (see each feature's comments)**
- MIPA: "Default" Attribute Set 422; Inactive tasks 500. Keylite 2-0-1: saving existing attribute groups/sets 400 (id sent as IRI). Andy Thornton staging: shipping service 34 422. PizzaExpressLive: content save dropdown never opens. Carbon: see above.

- 2026-11-22 dedupe: removed user-management.feature's create/delete scenario (address-book-management.feature's Background and outline end create and delete the same user), file-manager.feature's "Opening the File Manager" scenario (subset of the upload scenario) and 22 tabs-contain-expected-data.feature rows whose list first-item-redirects.feature already opens with the same tags (it fails on a list with neither rows nor an empty state). Orders, Navigation, Countries, Dashboard and Settings stay in tabs-contain.

## PER3-279: Peracto Admin v13 (React 16 -> 19) on the release env
Coverage: `src/features/CARBON_ADMIN_features/peracto-upgrade.feature` (73 scenarios, Carbon-only until v13 reaches other tenants; promote then and copy the new mapping keys/files). Live findings 2026-11-25, release vs staging (same API):
- Nav, routes, list data, exports, imports, pagination/sort, settings tabs, modals all behave identically.
- Content editor UI was redesigned (labelled toolbar, Add blocks / Block settings panel, click-to-add, per-block toolbar with Move/Add/Duplicate/Delete). On a new page the left settings panel covers the canvas; close it (`content-toggle-settings`) before clicking blocks.
- Navigation menu trees now sit in their own 576px scroll box and are virtualised (react-sortable-tree): only ~13 rows exist in the DOM, and a just-added item is appended at the end until a reload re-sorts it. The "should appear in" assertion and the menu-removal step now sweep the scroll box (`support-functions/virtual-scroll.ts`).
- Login error class changed `text-danger` -> `!text-danger`; every admin tenant's login.json now uses `contains(@class,'text-danger')`.
- reCAPTCHA on the release host: "Invalid domain for site key", so Forgotten Password returns "Recaptcha token not in header" there (staging fine). Env config, not code: the host needs adding to the reCAPTCHA key.
- `features.uploads` is off on Carbon, so the hardened upload file-type check (pdf/txt/png/jpg/jpeg only) can't be exercised here.
- Order export needs a Start and End date (Download disabled until both set); filename `order_export_<from>_to_<to>.csv`. Pick list Download builds `<yyyymmdd>_PICK_SHEET.pdf` in the browser. Imports are async (worker), typically under a minute.
- "Every task's play button": cleanup_old_import_data AND cleanup_old_data give no toast on both envs (pre-existing).
- Product "Manage Menu Item Relations" opens nothing and sends no request on both envs (pre-existing, not PER3-279).
- A new page's default "Edit me!" content only becomes a `text-component` once saved, so block counts differ before and after a reload.

## Tips for extending
- Build and verify new shared admin scenarios on Carbon staging first, then roll mappings out to all tenants.
- New tenant: copy `pages.json` + all `mappings/*.json` from this folder (not a customised tenant), then fix gaps found on the first live run.

_Last reviewed: 2026-11-25. Sources: memory notes + feature file comments._
