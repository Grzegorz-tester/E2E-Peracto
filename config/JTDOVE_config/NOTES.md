# JTDOVE automation notes

JT Dove storefront (builders merchant, Peracto on Next.js, Opayo card payments, Algolia search, Kerridge ERP stock). Runs `src/features/JTDOVE_features/` (27 features as of 2026-11-18). Admin is a separate project: see `config/JTDOVE_ADMIN_config/NOTES.md`.

## Environments
- `env/JTDOVE_STAGING.env` -> https://staging.jtdove.pub. Free rein: real orders (Opayo sandbox), fixtures, account edits.
- `env/JTDOVE_RELEASE.env` -> `release_branch` = https://4-4-0.jtdove.pub (added 2026-10-22). Treated as staging (real orders OK). The host changes per release: update `hosts.json` AND the env's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL` literals.
- No `JTDOVE_PROD.env` exists (as of 2026-10-23). Production is www.jtdove.co.uk; if one is added, all CLAUDE.md production rules apply.
- Both envs: `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=25000`, `BLOCK_REQUEST_HOSTS=cookiebot.com cookiebot.eu` (Cookiebot banner blocked rather than dismissed).
- Both envs also set `API_BASE_URL=https://staging-api.jtdove.pub` and `ALGOLIA_APP_ID`/`ALGOLIA_SEARCH_KEY`/`ALGOLIA_INDEX=staging_jtd` (2026-11-18). The release storefront (4-4-0) runs on the staging API and Algolia index too (checked in its JS bundle). The Algolia key is the public search-only key shipped to every browser.

## Test accounts and data
- `users.json` types: `logged in` -> `JTDOVE_LOGGED_IN_EMAIL`/`_PASSWORD`; `credit` -> `JTDOVE_CREDIT_EMAIL`/`_PASSWORD`; `guest`; `admin` -> borrows the admin project's `JTDOVE_ADMIN_ADMIN_*` via `credentialsEnvPrefix` (no duplicate in `.env`), used only for admin API calls (`I authenticate against the API as the "admin" user`).
- `logged in` = shared trade account (staging user 62, account 103128, greets "Hi Fred"), customer group Cash Account (card only). SHARED with other people:
  - Profile phone must be restored to its original value if a profile-edit run dies mid-way (the scenario remembers and restores it).
  - Never change its password (profile "Reset Password" opens an in-page Change Password form, no email).
  - Keep wishlists "Velstar Test Wishlist" (id 26, read-only fixture) and "Greg new wishlist". Clean up `qa-` addresses/wishlists after failed runs.
  - Never submit Make a Payment (it is disabled anyway: account balance is 0).
  - Saved address was in Leeds (outside the delivery area) until at least 2026-10; on 2026-11-19 the default delivery address was Harrogate HG1 1XX, which IS in the delivery area (billing still LS10 1AA). Others edit it, so `logged-in-delivery-checkout.feature` depends on it: check it first if that fails on "outside delivery area".
- `credit` = staging user 73 "Velstar Test Credit" (same account 103128, Credit Account group, payment type "account" only), created 2026-10-23. Default delivery/billing address saved (NE46 4DQ). Review & Pay shows "Pay on Account" (same testid as PROCEED TO PAYMENT), no Opayo.
- Credit user 73 holds exactly 20 wishlists "Velstar Test Pagination 01".."20" (ids 217-236), created 2026-11-18. DO NOT DELETE: they back `wishlist-pagination.feature` (15 per page -> 2 pages). 20 is also the per-user cap (API: "maximum Wishlists for User has been reached"), so the credit user can't create any more lists.
- New users: the admin API cannot set passwords; send the reset email and have the user set it.
- Promotions 15-26 (identifiers `velstar-test-*`, codes `VELSTAR*`, code-only) back `promotions.feature`. DO NOT DELETE. Full list and values in the feature header. VELSTARLIMITEMAIL is already used once by the shared account (intended).
- Test products (picked 2026-10-23 from the public Algolia index `staging_jtd`):
  - 310239 Marine Plywood (`test-product`): JT Dove "Delivery" type, main product; £56.98 ex VAT / £68.38 inc VAT (priority-promo scenario assumes this price).
  - 203734 neck warmer: courier only, no C&C. 668087 overflow tee: C&C at 2-3 branches. 351725 building sand: C&C at ~20 branches.
  - 791490 scotia: min qty 12. 518913 brick: multiples of 520. 278874 batten: timber length rows. 360384 sealant: Multibuy 3+/6+.
  - If one becomes unpurchasable, re-pick from Algolia with the same criteria (fields `shippingServiceType`, `minimumOrderQuantity`, `timberProduct`, `attributes.offer_type`) and update `pages.json`.
- Order data: use "Velstar" wherever possible (name "Velstar Test", address lines, notes). Guest delivery uses postcode NE46 4DQ (Hexham), inside the delivery area.
- Staging data is ours to shape (per user, 2026-10-23): create fixtures in staging admin/API ourselves, no need to route through QA. Still ask before submitting anything that emails real JT Dove staff.

## Known site defects (expected red)
- `/privacy-policy` (newsletter block link) and `/cookie-policy` (footer) 404 on staging; `/cookie-policy` also 404s on production (2026-10-22). `footer-newsletter-signup.feature`.
- Branch finder town search: "Google script not loaded". `branch-finder.feature` (2026-10-05). The A-Z letter filter keying on the full branch name (only J and N enabled) is CLIENT-APPROVED behaviour (user, 2026-11-23); the scenario now asserts it and passes. Revisit if the client reviews it.
- Price sort broken by "9XB TEST Product" (shows £19.99, sorts like ~£12). `products.feature` (2026-10-06).
- Home promo links to the production login.
- Opayo Cancel after a decline -> `/checkout` 404, on staging, 4-4-0 AND production. `payments.feature` (2026-10-23). Worth raising via the AM.
- Wishlist Share POSTs but gives no confirmation; its footer CLOSE is a submit button that doesn't close (X works). `wishlist.feature` (2026-10-23).
- Release only: after Opayo payment the browser returns to the STAGING host's `/checkout/thank-you` (404) instead of 4-4-0; orders are created fine. Thank-you heading check goes red; needs dev team (2026-10-22).
- Suspected, not asserted: promotion "Limit Total Uses" not counted for code promotions (VELSTARLIMITTOTAL uses stayed 0); raised with QA.
- Shared account (user 62): wishlist 18 returns 500 from `GET /wishlists/18`, and the list endpoint 500s whenever a page includes it (default page size; `itemsPerPage=10` page 2). My Lists only shows 3 of its 24 lists. Not caused by deleting a product (tested 2026-11-18: a deleted product drops cleanly out of a wishlist). Staging data issue; worth raising via the AM.
- Suspected (2026-10-05): added-to-basket drawer "GO TO CHECKOUT" did nothing; scenario retries, so red means genuinely broken.

## Quirks and gotchas
- Hydration race wipes filled inputs: after every page load or redirect (e.g. `/checkout/delivery`) use `I wait for the page to settle` before filling.
- RETRACTED: "search Enter/magnifier broken" (2026-10-06) was the hydration race, not a site bug.
- Loqate drops fast-typed input: use `I pick the first Loqate address for the postcode "..."` (types 150ms/key, retries). One-off Loqate failures are flakes.
- Address-book delete confirm is a "Yes" button rendered uppercase by CSS (`text-is('YES')` fails): use the `__delete-address-yes-button` testid. Delete button is a sibling of `address-book-delivery__address-N`.
- Logged-in checkout sign-in auto-advances to `/checkout/delivery`.
- Login takes ~22s on staging; newsletter/profile saves can take >10s. The profile page keeps serving the pre-save value for a while, so persistence is checked with "reload until ... contains", not one reload.
- CloudFront 403 "request could not be satisfied" on review-and-payment and newsletter server-action POSTs (2026-10-07) after heavy runs: cleared by itself within hours. Not test-fixable; wait and rerun.
- Live ERP data drifts: product 310239 had 0 stock everywhere and Invoices went empty (2026-10-07), both recovered within hours. Check stock/account state before blaming tests. Stock and invoices both come from Kerridge: when C&C and Invoices go red together, suspect the Kerridge connection first.
- 2026-11-18: EVERY branch showed 0 stock on every product checked (plywood, cement, overflow tee, sand: 0/25 branches selectable), so every Click & Collect scenario failed at "first enabled Select this branch". CONFIRMED 2026-11-19: the staging Kerridge connection was down. Check with a few PDPs' branch pickers before debugging.
- 2026-11-19 afternoon: Kerridge reported back, but a rerun of the 8 Kerridge-dependent features (54 scenarios) was still 36/54 with the same 18 reds, and plywood still had 0/25 selectable branches at 14:32 UTC. Old Velstar Test content pages 327-329 (2026-08-31) deleted the same day.
- 2026-11-20: Kerridge restored on staging (plywood 13/25 branches). Same 54-scenario rerun: 52/54, no retries. All C&C, Invoices and both logged-in delivery checkout scenarios (incl. case 87) pass. Only reds: Opayo cancel 404 (known defect) and related products (Algolia Recommend, unchanged).
- 2026-11-18 full staging regression baseline: 165/191. All 26 reds accounted for:
  - 9 C&C stock outage: basket-shipping-and-collection x4, basket switch to C&C, logged-in C&C, pay on account, PDP C&C, PDP no-stock rule.
  - 9 known defects: privacy link, reset password, branch finder x2, price sort x2, home production login, wishlist share, Opayo cancel 404.
  - 5 Invoices: "No results" for account 103128. Invoices come from Kerridge too, so most likely the same Kerridge outage (not separately confirmed).
  - 1 related products: `algolia-related-products` renders empty and Algolia Recommend answers "No recommendations found for the given index and model" for `staging_jtd` (passed 2026-10-22). Cause unconfirmed. `product_indexer` was run that day for the Algolia sync test, but reindexing records shouldn't drop a Recommend model. Check the Algolia dashboard or ask the devs.
  - 2 one-offs that passed on an isolated rerun: home page load timeout, outside-delivery-area add to basket. 2 more passed only on retry (footer sitemap, PLP filter).
- Branch stock changes between page loads and can't be set in admin: scenarios pick "first enabled Select This Branch" rather than a named branch.
- Basket groups lines into "Collect at Branch X", "Delivery" and courier sections; one collection branch per basket. Mixed order checkout: sign-in -> click-and-collect -> delivery -> billing -> review -> Opayo.
- Basket is per browser session, not per account: a fresh login starts empty.
- Checkout totals are ex VAT; Opayo charges inc VAT. VAT toggle is site-wide, so scenarios switch it back.
- Opayo sandbox: declined card = any non-test PAN; a wrong CV2 is NOT declined.
- Creating a wishlist redirects to its page (no toast); rename needs a reload to show.
- PLP has two "Clear all" buttons: use the `[role=dialog]` one while the filter drawer is open.
- `/sitemap` returns 413 to curl (too large uncompressed) but loads in a browser; `/sitemaps/*.xml` only exist on prod.
- Ask a question / profile email use JS validation, not native `required`/`type`.
- Content pages and menus (confirmed live 2026-11-19): a content page has no storefront URL until it is in a menu (no menu item = 404). Pages outside the visible navigation live in the "Orphaned pages" menu. `POST /menu-items` needs `menuCode` (orphaned_pages/main_menu/footer), `identifier` = the NUMERIC content id (an IRI or a `content` field 500s), `itemType: content`, `linkType: external`, `path` = slug, and `parent` for a footer column (footer "About JT Dove" = menu item 238). Content edits reach the storefront in ~40s. Menus are cached separately and unpredictably: a new footer link took 19s, ~12 minutes and >15 minutes on three tries (2026-11-19). Worth raising with the devs via the AM: admin navigation edits may not show for 15+ minutes.
- Logged-in payment does a live account-status check against Kerridge: with Kerridge down, PROCEED TO PAYMENT shows "we are unable to check the status of your account at this time" and never reaches Opayo (the shared Opayo step now quotes that message).
- Algolia: objectID = Peracto product id. A new product is NOT indexed on save; it appears only after the "Product Indexer" task runs (nightly 03:00, or `GET /tasks/product_indexer/run`, ~105s for the catalogue). A delete IS synced at once (gone within ~30s). `algolia-product-sync.feature` triggers the indexer itself.
- Admin API orders: filter with `/orders?reference=<6 digits from the thank-you page>`. Paid orders are `status: successful`; declined/abandoned stay `pending`. A mixed basket is one order with three lines (`shippingServiceType` delivery/courier/click_and_collect); courier adds a shipping charge (413 pence ex VAT), delivery-only orders have 0.
- Header utility links "Contact Us" and "Call your local branch" go to `/contact` and `/branches`, not `mailto:`/`tel:` (manual cases 30-32 are stale).
- Account applications (2026-11-18 exploration, never submitted): every Next fires a Next.js server action POST with no form data (look-ups, safe). Credit: 3 steps; step 2 fields depend on Type of Organisation (Sole Trader adds personal details plus a second Loqate address; a limited company doesn't); step 3 is a declaration (trading name, position, names, email, terms checkbox) with "Submit" on the same `multi-step-form__next` testid, still disabled once filled (custom checkbox or reCAPTCHA). Dropdowns are Radix comboboxes ("Please select..." / "Choose Your ..."), not native selects. Cash: a third-party `#sf-digi` iframe intercepted clicks on its dropdowns. Self-build: step 2 is already the submission step.

## Coverage and gaps
- Covered: guest delivery and logged-in C&C real orders (`@places-real-order`), pay on account, payment decline, basket shipping/C&C, PDP rules (min qty, multiples, timber lengths, multibuy), promotions, wishlists incl. share and pagination, account (profile, addresses, invoices, orders), branch finder, header/footer, search, mobile drawer, account application validation (step 1).
- Added 2026-11-18 (upgrade tickets): the three order scenarios check the order reached Peracto admin via the API (status, email, lines, postcode, courier charge); `algolia-product-sync.feature` (cases 223-225, throwaway product, After-hook cleanup); `platform-upgrade-health.feature` (real 404s, 200s incl. `?page=2`, `/account` 307 to login, no failed fetch/XHR or console errors across home/PLP/PDP/search/branches/basket); drawer click-outside; wishlist pagination/columns.
- Added 2026-11-19: `admin-content-on-storefront.feature` (case 206: throwaway content page via the admin API, served at /<slug>, an edit shows within ~40s); `admin-navigation-on-storefront.feature` (case 208, footer link via a footer menu item) is tagged `@menu-cache` and kept OUT of regression because the menu cache is unpredictable (19s, ~12 min, >15 min on three tries): run with `./run_tests.sh menu_cache` (profile added 2026-11-23; `--tags @menu-cache` alone runs nothing, it is ANDed with the profile tag); `algolia-product-sync.feature` now also checks the new product's PDP is live and 404s once deleted (case 209); `logged-in-delivery-checkout.feature` (logged-in card delivery order checked in admin, and case 87 declined card); `mobile-shopping.feature` (no sideways scroll on 7 core pages at 390px, guest add to basket to checkout start, drawer search).
- `@smoke` now matches the QA smoke export (42 scenarios): `./run_tests.sh smoke` is the quick check after each upgrade deploy.
- Qase (exports JTDOVE-2026-11-18.json, 144 regression cases; JTDOVE-2026-11-18 (1).json, 22 smoke cases): automated = 122/144 regression, 19/22 smoke (2026-11-19). Covered ids are listed below; mark them with `scripts/qase-mark-automated.ts --project <code> --only <ids>` (needs QASE_API_TOKEN, not in .env yet).
  - Regression covered: 20,22,23,25,26,27,28,33,35-42,46-51,53-55,67-72,86,87,88-95,97-104,106-115,117,119,133-138,140-152,154-156,158-167,169-191,214,216,219,223-225.
  - Smoke covered: 192-201,203,205,206,208,209,210-212,213 (210/211 by the admin project's shared suite).
- Not automated, and why:
  - Stale in Qase: 21, 24 (no such header items), 30-32 (header links aren't tel/mailto), 34 (single "Sign In | Register" link to /login), 139 (no Local Branch), 202 (no self-registration). 29 and 56 have no steps.
  - Blocked by data: 116/118 (basket C&C disabled/enabled by branch) need live branch stock, which was 0 everywhere on 2026-11-18; 153 (Make a Payment with a valid amount) needs an outstanding balance on account 103128 (it owes nothing; balance comes from Kerridge).
  - Needs sign-off: 52 (contact form) and 217/218/220-222 (full account applications and activation) email real JT Dove staff; ask the AM before automating a real submit.
  - Other: 96 (Limit Total Uses, suspected defect), 105 (postcode branch search, same Google script defect as town search), 168 (wishlist Quick Add suggestions aren't plain links), 204 (password change needs a dedicated account), 207 (CKFinder image upload is an admin UI widget; the storefront side adds little over 206).
- Gaps: none known beyond the cases above. Guest C&C is covered by the mixed-basket checkout (2026-10-23).

## Tips for extending
- Staging footer has a "QA Smoke Test Page" link (absent on prod) if you need a test page.
- Promotions are easiest via the admin API (`staging-api.jtdove.pub`, bearer token from an admin login): amounts and `basket.subtotal` are in pence; PATCH is 405 (PUT the full GET body); `uses`/`emailUses` read-only; incompatibility is `promotionCompatibilities: [{"incompatiblePromotion": "/promotions/<id>"}]` (a plain IRI 500s).
- Record any new fixture (id/code) here as "do not delete".
- Scenarios that place orders need `@places-real-order` + `I require staging for this scenario`.
- API fixtures from a scenario: `I authenticate against the API as the "admin" user`, `I POST the API path "..." with the JSON body:` (doc string, `{{name}}`/`{{env.NAME}}` interpolated), then `I will DELETE the API path "/x/{{id}}" after the scenario` so a failed run still cleans up. Tag `@mutates-admin-data`. Admin entities need a slug (products) or a `user` IRI (wishlists).

_Last reviewed: 2026-11-18. Sources: memory notes + feature file comments + 2026-11-18 live session._

## Benchmarx Next.js 15 bug checks (BEN-379, added 2026-11-22)
The bugs linked to Benchmarx's Next.js 15 upgrade (BEN-389 to 395, 400 to 402) are now checked on JT Dove too, so its own upgrade catches the same breakages. All 21 new or changed scenarios passed on staging 2026-11-22.
- BEN-389 search ignores the term: search-drawer.feature, "honours the search term", "Page 2 of search results", "search for nonsense".
- BEN-390 branch page 500 after load: branch-finder.feature (Hexham details, existing), plus branch-hexham added to the console/network check in platform-upgrade-health.feature and to mobile-shopping.feature.
- BEN-391 branch finder spinner: branch-finder.feature "lists every branch" (existing).
- BEN-392 customer kitchens gallery modal: no JT Dove equivalent (no gallery or detail modal); not added.
- BEN-393 blog pagination ignores ?page=: JT Dove has no blog (/blog, /news 404; /inspiration is an empty content page), so the same searchParams check runs on a direct /category/Special-Offers?page=2 and /search?q=plywood&page=2.
- BEN-394 full page reloads: header.feature "navigate client-side without a full page reload".
- BEN-395 newsletter never confirms: footer-newsletter-signup.feature (existing).
- BEN-400 name sorts missing: products.feature sort option outline (Featured, Price low/high, Name A-Z/Z-A).
- BEN-401 page size: products.feature "16 products per page" (JT Dove shows 16, Benchmarx 15).
- BEN-402 filter lost when the drawer closes: products.feature "Applying a filter narrows the results" now waits after closing the drawer before checking.
- 2026-11-22 duplicate trim: removed header Roofing/Kitchens menu rows, header Branches row, logo-home scenario (covered by the client-side nav scenario), wishlist PDP-save, wishlist 26 lines and shared-account search scenarios (covered elsewhere in wishlist/wishlist-pagination), my-account menu outline cut to Profile. Kept on purpose: products sort-option price rows and payments declined-card scenario (their covering scenarios are known-red), account-actions add/delete address (has a unique count check).

## Release 4-4-0 run of 2026-11-23 (181/203)
- The release now has its OWN API: https://4-4-0-api.jtdove.pub (same admin login; orders 010683-010688 from this run are there). It still searches the staging Algolia index (staging_jtd). `env/JTDOVE_RELEASE.env` API_BASE_URL switched to it; the content page, Algolia sync and pay-on-account scenarios then passed (3 of the 22 reds were this config).
- 9 reds are the known staging defects (letter filter [since accepted as approved behaviour, now green], town search, newsletter privacy link, home production login link, Opayo cancel 404, price sort x2, reset password [2026-11-23: NOT a site defect, stale selector; the confirmation shows in reset-password-form__success, fixed and green], wishlist share).
- 10 reds are release-only (green on staging), all confirmed by hand except where noted:
  - Pagination ignores the page (3): clicking Next changes the products but the URL keeps no ?page=, and a direct ?page=2/3 shows page 1 (category and search). Same symptom as Benchmarx BEN-393.
  - Soft 404: /branches/velstar-no-such-branch returns 200 (staging 404).
  - /cookie-policy (footer) is a 404 on release, 200 on staging (missing content in the release backend, most likely).
  - Thank-you page is a 404 after a successful Opayo payment (4: guest delivery, mixed basket, logged-in delivery, logged-in C&C). Orders ARE created and paid in the release API. CONFIRMED 2026-11-23 (order 010691, successful): after paying, Opayo returns the customer to https://staging.jtdove.pub/checkout/thank-you, which can't find a release order, so the customer sees a 404. The Opayo return/notification URL on the release is still configured for staging (same as 2026-10-22, now visible because the release has its own backend).
  - Delivery step: the "Please enter a contact number to continue." hint is gone (Continue is still disabled until a mobile is entered). Possibly intentional; confirm.
- Release delivery showed "Dove Delivery (Free): FREE" for the guest Hexham address (staging charges £11 ex VAT for the shared account's address): separate backend data.
- Second full run 2026-11-23 12:23 (after the API fix): 128/203 in the PDF, but 61 of the reds were `ERR_NAME_NOT_RESOLVED` for 4-4-0.jtdove.pub on the runner (the run lost DNS partway; every feature from products.feature onward, alphabetically, died opening its first page). Rerunning those 8 features gave 58/65, all 7 reds known. Combined: 184/203. The 19 reds are exactly the 9 known staging defects plus the 10 release-only ones above; nothing new. If a whole tail of a run fails on `ERR_NAME_NOT_RESOLVED`, it's the runner's network, not the site.
- Third full run 2026-11-23 15:01: 184/203 in one go, no retries, no network errors; the same 19 known reds.
- Branch finder on 4-4-0 (checked 2026-11-23): Google Maps rejects the release host (`RefererNotAllowedMapError`), so no map and no town search box at all. On staging the map loads, but the Maps script is requested with `libraries=core` only (no `places`), so the town search logs "Google script not loaded" and never suggests anything. The A-Z filter is identical on both: only J and N are enabled because it keys on the first letter of the full branch name ("JT Dove ...", "Nordstrom Timber"); client-approved, test now expects it.
