# KOOLTECH automation notes

KOOL (Kooltech) trade storefront for air conditioning and refrigeration supplies, on Peracto. Runs `src/features/KOOLTECH_features/` (18 features, about 58 scenarios on staging/release, 56 on prod once real-order scenarios are filtered out). Renamed from KOOL to KOOLTECH on 2026-10-19, so older memory notes, comments and commits say "KOOL".

## Environments
- `env/KOOLTECH_STAGING.env` -> `staging.kooltech.pub`. Staging: real orders and data changes are fine.
- `env/KOOLTECH_RELEASE.env` -> `release-2-19-0.kooltech.pub` (added 2026-09-15). Treated as staging (real orders OK). The host changes with each release: update `hosts.json` `release_branch` AND the env file's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL` literals together.
- `env/KOOLTECH_PROD.env` -> `www.kooltech.co.uk`. Production, read-only: no orders, no form submissions. `SCRIPT_TIMEOUT=20000`.
- Admin site is a separate project: see `config/KOOLTECH_ADMIN_config/NOTES.md`.
- Staging and release-2-19-0 have different account data (see below), so a failure on one host only is not automatically a code regression.

## Test accounts and data
- `users.json` user types: `logged in`, `quotes user 2`, `guest`.
- `.env` names: `KOOLTECH_LOGGED_IN_EMAIL/_PASSWORD`, `KOOLTECH_QUOTES_USER_2_EMAIL/_PASSWORD` (staging + release, `PROJECT=kooltech`); `KOOLTECH_PROD_LOGGED_IN_*` and `KOOLTECH_PROD_QUOTES_USER_2_*` (prod, `PROJECT=kooltech_prod`). Renamed from `KOOL_*` on 2026-10-20.
- `logged in` MUST be the separate staff quote-builder account (has `/account/staff-quotes`, Invoices, Make a Payment). If `KOOLTECH_LOGGED_IN_*` is missing it falls back to the generic `LOGGED_IN_*`, which is the same person as `quotes user 2`: this silently broke the quote tool (12 failures) and checkout delivery options (5 failures) on 2026-09-28.
- `quotes user 2` is a plain trade account: read-only Quotes, no Invoices link. business-rules.feature asserts exactly this difference. NEEDS CONFIRMATION (2026-10-24): this account now sees Invoices on both staging and prod, so that business-rules scenario is red until QA confirms whether the rule or the account changed.
- A credential variant with a trailing "!" was tried 2026-09-28 and gets "Invalid credentials"; `.env` keeps the original. Credentials were restored after the 2026-09-16 `.env` wipe and re-checked on 2026-10-22 (prod pair included).
- Neither account is F-Gas registered, and no F-Gas registered account exists, so the "unlocked" gas purchase path and bottle/surcharge messaging can't be tested.
- Fixture quote: quote-tool-products.feature duplicates the existing "smoke test" quote in its Background. Don't delete it.
- Test products (`pages.json`): `cable-pdp` (`/products/1-5mm-x-4-core-sy-cable-x-1-metre`, sold in 100 m drums, minimum quantity 100, so quantities must be multiples of 100), `chemicals-plp` (`/category/chemicals`, guests can add to basket), `gas-pdp` (`/products/r407f`, F-Gas gated), `hose-set-pdp` (F-Gas gated, no Add to basket for guests).
- The account's address book shows 4 cards per section until "View more" is clicked, and collects leftover "Velstar qa-..." / "TestAuto" addresses. Safe to delete leftovers by hand.

## Known site defects (expected red)
- Branch finder Google Places autocomplete never works ("Google script not loaded": Maps loads after the component initialises). Staging and release, confirmed 2026-09-28. branch-finder.feature's header still says its selectors are unconfirmed guesses.
- Footer "About us" link `/about-us` returns 404. Staging and release, 2026-09-28.
- Quote tool: a section's own Discount button does nothing and resets to 0 after save (quote-tool-products.feature, "confirmed site bug" scenario asserts the broken behaviour). Confirmed 2026-08-18, still present 2026-09-28.
- Quote tool: duplicating a section zeroes every other section's subtotal and hides their product tables (2026-08-18).
- Mobile nav drawer: clicking the backdrop closes it but the click falls through to the category link underneath. Tests close with Escape instead (2026-08-19).
- Subcategory nav links exist in markup but carry a bare `hidden` class that never un-hides at any width (2026-08-19). Not covered.
- Guest card purchase journey (purchase-journey.feature) is incomplete (guest sign-in step not built) and guest pricing is flaky, so it is an accepted failure as of 2026-09-28.
- Staff quote list Company Name filter (quote-tool.feature, "Filtering by company name"), red since 2026-10-24 on staging: 9 of the 10 unfiltered rows show "Greg Test Test Test Companyy - AEROCOOL LTD", yet filtering on "AEROCOOL", "Greg" or that full text returns nothing ("AARON" filters fine). The API filters on `quoteCustomer.companyName`, which apparently isn't what the column displays. Unconfirmed whether this is a site defect or changed quote data; needs QA input before changing the test term.
- Final KOOLTECH_RELEASE run 2026-09-28: effectively 54/58, the 4 reds being the branch finder, `/about-us`, section discount and guest card journey.

## Quirks and gotchas
- **Production orders incident (2026-09-11):** real pending orders appeared in KOOL's production admin from the test account. Cause (inferred): ad hoc live "verification" against production bypassed cucumber's tag filter. Fix: `@places-real-order` scenarios start with `Given I require staging for this scenario`, card-payment steps refuse production, and since 2026-10-20 `isProductionRun()` hard-gates `_PROD` envs. Lesson: an exploratory session on prod must stop before checkout. The account manager still needed to be told (by call) about the pending orders as of the memory note; check before acting on them.
- Add-to-basket then navigate to `basket` with no wait empties the basket 3/3 times. Use the settle / "I wait for the basket update to complete" step after every add.
- Guest pricing and Add to basket are per-product gated AND intermittently missing even for the same product and session (staging pricing service flakiness). Most purchase/checkout scenarios therefore run as `logged in` on `cable-pdp`.
- F-Gas gating: on gas products, guests (since 2026-09-28) and logged-in non-registered users both see a DISABLED Add to basket plus the warning. "PDP add to basket" is scoped to exclude "You may also like" cross-sell cards that share the testid.
- Verifone card payments always go through Cardinal Commerce 3DS. Use the "frictionless" numbers in `payment-test-cards.ts`; the classic test cards trigger a challenge that never resolves headless. Cardinal starts failing after several attempts in a short window, so don't add redundant card-payment scenarios.
- Checkout is one page with accordion sections (Sign In, Delivery, Billing, Review and Payment). PROCEED stays disabled until Telephone is filled and the saved billing address is explicitly clicked.
- Duplicating a quote intermittently shows "Internal Server Error" client-side although the duplicate is created; a save/reload after many stacked edits can 500. Keep quote scenarios short and independent.
- `quote-builder.ts` save detection used to hardcode a `staging-api` host; it now matches the `/quotes/<id>` PUT on any host.
- PLP pagination is prev/next chevrons plus an "N of M" indicator that replaces results; assert on the indicator, not card counts. Filter checks also compare the indicator (prod's first facet exceeds a page so card count never drops).
- Account menu differs by database: Invoices/Make a Payment visibility can flip between staging and release for the same login. That is account data, not a regression.
- Footer link check skips linkedin.com (999 anti-bot), plus facebook/twitter/x.
- Sitemap is tabbed with Shop as the default; the `sitemap` page id is `/sitemap/products`.
- Order search uses the first listed order ("first order number" key) because hardcoded order numbers aged out of the date range.

## Coverage and gaps
- Covered: header, nav menu, PLP/search, PDP, basket, checkout, payment (declined card, PROCEED gating, Make a Payment field), purchase journeys (logged-in Pay on Account places a real order on staging/release), quote tool list and products tabs, business rules (F-Gas, Invoices visibility), my account, account gaps (address add/delete), recently viewed, VAT toggle, footer, SEO/sitemap, branch finder.
- Not covered: Google Pay / Apple Pay, Outstanding Balance and Pay by Link, real quote creation/deletion of real records, full registration (needs F-Gas certificate upload and creates a real trade account), Click & Collect branch search (API 200 but no results rendered), "Add new address" form submit (stayed disabled, unexplained).
- Prod divergence (confirmed 2026-10-24): the Gas nav link goes to `/category/gas-refrigerant` on prod but `/category/refrigerant` on staging/release, and the gas product is `/products/r407f-refrigerant-9kg` on prod (`gas-pdp-prod`) vs `/products/r407f` (`gas-pdp`); each 404s on the other site. Handled with per-environment Examples tagged `@not-on-production` / `@production-only` in navigation-menu.feature and business-rules.feature. On prod a guest gets NO Add to basket button on gas products (staging/release: disabled button).

## Tips for extending
- Any new order-completing scenario: tag `@places-real-order` and start with `Given I require staging for this scenario`.
- Use `logged in` + `cable-pdp` for anything needing a reliable price/basket.
- Before calling a release-only failure a regression, run the same scenario on staging and check which account `logged in` resolved to.
- Mark checkout data as "Velstar Test".

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
