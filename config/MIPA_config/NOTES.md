# MIPA automation notes

MIPA Paints trade storefront (refinishing/industrial paints and coatings), Next.js on Peracto (Carbon-based). Runs `src/features/MIPA_features/` (20 features, about 81 scenarios). Many files were originally cloned from HIB and fully rewritten; if a comment or key looks like HIB (bathrooms, "place-order", "solas"), it is contamination.

## Environments
- `env/MIPA_STAGING.env` -> `staging.mipa-paints.pub`. Staging: real orders fine. Use this for all MIPA storefront runs at present.
- `env/MIPA_RELEASE.env` -> currently `feature-next-15.mipa-paints.pub`. DORMANT since 2026-10-14: the branch was merged to staging and the host destroyed (TLS error = dormant, not broken). Kept unchanged until the next release host exists; then update `hosts.json` `release_branch` AND the env's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL` literals. Release hosts are treated as staging (real orders OK).
- Release history: `release-2-8-0` -> `release-2-8-1` (2026-09-15) -> `feature-next-15` (2026-09-21). feature-next-15 used `staging-api`, the same backend as staging, so data matched; 2-8-1 had its own backend (`2-8-1-api`) and its own data.
- `hosts.json` also has `dev` (`localhost:3001`). No production env exists for MIPA.
- `SCRIPT_TIMEOUT=25000`. Neither env sets `PROJECT=`, so credentials resolve from the generic variables.
- Admin site: see `config/MIPA_ADMIN_config/NOTES.md`.

## Test accounts and data
- `users.json`: `admin`, `logged in`, `guest`. `.env`: generic `LOGGED_IN_EMAIL/_PASSWORD` (no `MIPA_LOGGED_IN_*` override exists).
- The `logged in` account is a trade/credit customer: checkout ends in Pay on Account with a mandatory PO reference, no card gateway. It is shared, so heavy back-to-back runs against it can interfere with each other.
- **Fixture, do not delete:** staging admin promotion id 17 "Velstar Test 1% Off", identifier `velstar-test-1-percent`, code `VELSTARTEST1`, no conditions, 999999 uses. Backs basket.feature's valid-promo scenario (expected -£0.13 on £12.23, total £12.10; the site rounds the discount up). A release branch with its own backend will not have it.
- Test product: `test-product` = "Mipa 2K HS F37 Filler (1L) Light Grey", SKU 229510000 (admin product id 836 on 2-8-1). Used for deterministic price/UOM checks and header search.
- Address book: "Fred Smith" (1st) is the default delivery address; account-actions.feature restores it every run. 8+ leftover "Velstar qa-<ts>, 123 Test Street" addresses exist (likely from the admin address-book suite), not yet investigated.
- My Lists: pre-existing lists (QA Regression List, QA Test List, march list, My new list) are not ours. Lists named `qa-<ts>` are ours and safe to delete by hand if a run fails midway.
- The account has no invoices (genuine "Sorry, no results" state).
- A fresh browser session always starts with an empty basket.

## Known site defects (expected red)
- Order detail: opening any `/account/orders/MSO-x` falls back to the Orders list (my-account.feature last scenario). On feature-next-15 the API call returned 500; on staging/2-8-1 it redirected without calling the API. Confirmed 2026-09-25, still listed as red in memory; re-check on staging.
- Sitemap category and article links are all `display: none` with no toggle (looks like a rendering bug, not chased; doesn't fail the test).
- Resolved: "All Refinishing Products" 404 (fixed by MIPA 2026-10-01); product title mismatch on SKU 229510000 (fixed via admin data edit 2026-09-15); Quick Order CSV upload 500 (release-2-8-1 only, passed on feature-next-15; quick-order.feature's header comment still describes it as current).

## Quirks and gotchas
- Header redesign 2026-10-14: desktop is now a mega menu; the side drawer is mobile-only (`brand-bar__menu-button`). Drawer scenarios resize to a mobile viewport first. "Menu draw search bar" is `[data-testid='nav-menu__popup-header'] input`.
- Algolia header search needs `I wait for the search results to update` (debounce race).
- PLP product click sometimes silently no-ops (Next.js router "Failed to fetch"); use the retrying click variant. Same for Industrial Product Finder SEARCH / RESET SEARCH (hydration race).
- Industrial Product Finder uses Radix comboboxes with cascading required fields; options are pre-filtered, so a "no results" search can't be driven from the UI.
- No add-to-basket on the PLP (only "View Product"). Guests see no prices; PDP offers "Add to Enquiry" instead.
- Basket mapping lives in `mappings/basket.json` (was a never-loaded `place-order.json`).
- Profile save shows no success message: confirmed via the noted PUT response plus a reload. Change Password checks are client-side only, so no real password change happens.
- Wishlist search filters only after clicking SEARCH, so the shared "clean up any leftover" step doesn't work here.
- Registration is a "Request an Account" enquiry form (needs the page-settle wait before filling).
- Category routes: refinishing PLPs moved under `/category/refinishing/...` (2026-09-25). A route that "times out reading text" may be a 404: check the page before adding waits.
- Delivery option "Courier delivery option" maps to "Next Day Courier Delivery - Under 30KG" (3 Day Courier was removed 2026-09-25).
- RETRACTED (2026-09-15): a "PDP quantity reverts to 1" site bug. Likely shared-account contention from many concurrent debugging runs; the user's manual retests were clean. The "click precisely" fix on the increment button was a separate real issue and stays.

## Coverage and gaps
- Covered: header, home, menu drawer, PLP (products.feature), PDP (UOM, quantity, wishlist create, guest enquiry), basket (qty, remove, invalid/valid promo), Quick Order CSV, checkout validation (no orders), customer-flow and quick-order Pay on Account orders (real orders on staging each run), my account tabs, account actions, wishlist, login, register, reset password, contact (Help & Advice tiles), footer, sitemap.
- Never clicked on purpose: Make a Payment (takes real payment), enquiry form Submit (emails MIPA staff), off-site enquiry tile forms.
- Not covered: valid order-number search (date-filtered, brittle), CSV "compress to closest UOM" (needs an admin setting), restrictions (`restrictions.feature.disabled` is an empty stub).
- The order-placing scenarios are not tagged `@places-real-order`; there is no MIPA prod env today, but tag them before adding one.

## Tips for extending
- MIPA and MIPA_RELEASE share this config folder, so a fix applies to both.
- Don't place more orders than needed: customer-flow and quick-order each place one per run.
- New test promotions/fixtures go in staging admin with the user's go-ahead, then get recorded here as "do not delete".

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
