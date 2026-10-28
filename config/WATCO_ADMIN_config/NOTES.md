# WATCO_ADMIN automation notes

Watco UK admin: the LEGACY server-rendered Peracto (v6.1, Symfony + DataTables) at `<storefront host>/peracto`. Not the React Peracto Admin, so it does NOT use `CARBON_ADMIN_SHARED_features`; it runs its own `src/features/WATCO_ADMIN_features/`. Storefront-side Watco knowledge lives in `config/WATCO_config/NOTES.md`.

## Environments
- `env/WATCO_ADMIN_STAGING.env` -> https://staging-uk.watco.pub/peracto (staging). Host includes `/peracto`, so the generic login step's `<host>/login` and `LOGIN_SUCCESS_URL` line up; page routes carry the `/peracto` prefix because routes replace the whole path.
- No prod env yet. `hosts.json` has `https://www.watco.co.uk/peracto`, but there are no prod admin credentials. The suite is read-only, so it is safe in shape for prod once an account exists.
- Other markets (staging-befr/benl/de/fr/ie/nl/pl.watco.pub/peracto) have SEPARATE user lists: the UK admin login is rejected on all 7 (checked 2026-10-24).

## Safety rules
- READ-ONLY suite by design (user, 2026-10-24): never create, edit, delete or Save. Detail pages are edit forms; scenarios only check they render.
- Deliberately excluded: Akeneo reporting pages (live API calls) and the export pages (Export Registered Users, Export Quote Report, product exports: they generate customer-data files).

## Test accounts and fixtures
- User type "admin": `WATCO_ADMIN_ADMIN_EMAIL`/`_PASSWORD` = Velstar "Test Automation" account (user 30520), Admin role added 2026-10-24.
- Fixture checked by `list-search.feature`: promotion 647 / VELSTARTEST1 (backs the storefront `basket-promo-code.feature`). Do not delete.

## Coverage (2026-10-24: 21/21 passing live, first run; 2026-10-28 extended to every Super Admin section, see feature files)
- logging-in (success, wrong password, unknown email, forgotten link), sections-load (Orders, Promotions, Users, Tasks, Q&A, Stockist settings, Permission resources), first-item-opens-detail (5 lists + order items), list-search (promo fixture, own user, storefront orders arrive, empty state).

## Account role: Super Admin required (RESOLVED 2026-10-28)
- With only Admin + User, Products, Categories, Attributes, Shipping, Store settings, Search settings, Import, Content, Articles, Templates, Form builder, Fields, Stockists, Settings, Redirects, Permissions and the banner pages were missing from the nav and served the "Uh oh, that's not good" page as a slow (~20-30s) HTTP 500, not a 403. An unknown /peracto URL gives a fast 404, so the routes do exist.
- Fixed by giving the Test Automation account (user 30520) ROLE_SUPER_ADMIN. Only an existing Super Admin can grant it: Admin users don't see the option in the Roles dropdown. All those sections then load (200).
- Gotcha: saving the user form while granting the role also reset the password once (login gave "Invalid credentials" until it was reverted). If logins suddenly fail after someone edits the account, check that first.

## Known defect: Bestsellers category edit page 500s (2026-10-28)
- /peracto/store/categories/edit/328 (Bestsellers, the 1st item in the category tree) returns HTTP 500 for a Super Admin; every other category sampled opens as "Edit Standard Category". Covered by its own scenario, expected to stay red until fixed. The generic category scenario opens the 2nd tree item for this reason.

## Quirks
- Wrong password and unregistered email both show "Invalid credentials." (no account enumeration).
- "Forgotten your password?" goes to the storefront's `/forgotten`, not an admin page.
- Headings are styled uppercase via CSS; `textContent` is mixed case ("Orders"), which is what the assertions read.
- DataTables search filters on `fill()` (input event); assert via `.dataTables_info` ("of 1 entries" / "0 entries"). The empty-state row (`.dataTables_empty`) is excluded from "list rows".
- The "Velstar Test" orders search is weak while our own order is newest (first row matches before filtering); its point is that storefront orders arrive at all.
- Saving a promotion with an empty end date fails ("Please enter a valid date and time").

_Last reviewed: 2026-10-24._
- 2026-10-28: Super Admin can only be granted by an existing Super Admin (the role isn't in the dropdown for Admin users). After the user reported the account was made Super Admin, a fresh login still saw the same nav and all 18 sections still returned 500. Not yet confirmed the role was actually saved on user 30520 on staging-uk.
