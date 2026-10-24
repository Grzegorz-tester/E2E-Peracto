# JTDOVE automation notes

JT Dove storefront (builders merchant, Peracto on Next.js, Opayo card payments, Algolia search, Kerridge ERP stock). Runs `src/features/JTDOVE_features/` (24 features, ~173 scenarios as of 2026-10-23). Admin is a separate project: see `config/JTDOVE_ADMIN_config/NOTES.md`.

## Environments
- `env/JTDOVE_STAGING.env` -> https://staging.jtdove.pub. Free rein: real orders (Opayo sandbox), fixtures, account edits.
- `env/JTDOVE_RELEASE.env` -> `release_branch` = https://4-4-0.jtdove.pub (added 2026-10-22). Treated as staging (real orders OK). The host changes per release: update `hosts.json` AND the env's `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL` literals.
- No `JTDOVE_PROD.env` exists (as of 2026-10-23). Production is www.jtdove.co.uk; if one is added, all CLAUDE.md production rules apply.
- Both envs: `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=25000`, `BLOCK_REQUEST_HOSTS=cookiebot.com cookiebot.eu` (Cookiebot banner blocked rather than dismissed).

## Test accounts and data
- `users.json` types: `logged in` -> `JTDOVE_LOGGED_IN_EMAIL`/`_PASSWORD`; `credit` -> `JTDOVE_CREDIT_EMAIL`/`_PASSWORD`; `guest`.
- `logged in` = shared trade account (staging user 62, account 103128, greets "Hi Fred"), customer group Cash Account (card only). SHARED with other people:
  - Profile phone must be restored to its original value if a profile-edit run dies mid-way (the scenario remembers and restores it).
  - Never change its password (profile "Reset Password" opens an in-page Change Password form, no email).
  - Keep wishlists "Velstar Test Wishlist" (id 26, read-only fixture) and "Greg new wishlist". Clean up `qa-` addresses/wishlists after failed runs.
  - Never submit Make a Payment (it is disabled anyway: account balance is 0).
  - Saved address is in Leeds, outside the delivery area, so the logged-in journey uses Click & Collect.
- `credit` = staging user 73 "Velstar Test Credit" (same account 103128, Credit Account group, payment type "account" only), created 2026-10-23. Default delivery/billing address saved (NE46 4DQ). Review & Pay shows "Pay on Account" (same testid as PROCEED TO PAYMENT), no Opayo.
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
- Reset password shows no confirmation after a valid email. `reset-password-page.feature` (2026-10-05).
- Branch finder town search: "Google script not loaded". A-Z letter filter keys on full name ("H" shows all). `branch-finder.feature` (2026-10-05).
- Price sort broken by "9XB TEST Product" (shows £19.99, sorts like ~£12). `products.feature` (2026-10-06).
- Home promo links to the production login.
- Opayo Cancel after a decline -> `/checkout` 404, on staging, 4-4-0 AND production. `payments.feature` (2026-10-23). Worth raising via the AM.
- Wishlist Share POSTs but gives no confirmation; its footer CLOSE is a submit button that doesn't close (X works). `wishlist.feature` (2026-10-23).
- Release only: after Opayo payment the browser returns to the STAGING host's `/checkout/thank-you` (404) instead of 4-4-0; orders are created fine. Thank-you heading check goes red; needs dev team (2026-10-22).
- Suspected, not asserted: promotion "Limit Total Uses" not counted for code promotions (VELSTARLIMITTOTAL uses stayed 0); raised with QA.
- Suspected (2026-10-05): added-to-basket drawer "GO TO CHECKOUT" did nothing; scenario retries, so red means genuinely broken.

## Quirks and gotchas
- Hydration race wipes filled inputs: after every page load or redirect (e.g. `/checkout/delivery`) use `I wait for the page to settle` before filling.
- RETRACTED: "search Enter/magnifier broken" (2026-10-06) was the hydration race, not a site bug.
- Loqate drops fast-typed input: use `I pick the first Loqate address for the postcode "..."` (types 150ms/key, retries). One-off Loqate failures are flakes.
- Address-book delete confirm is a "Yes" button rendered uppercase by CSS (`text-is('YES')` fails): use the `__delete-address-yes-button` testid. Delete button is a sibling of `address-book-delivery__address-N`.
- Logged-in checkout sign-in auto-advances to `/checkout/delivery`.
- Login takes ~22s on staging; newsletter/profile saves can take >10s. The profile page keeps serving the pre-save value for a while, so persistence is checked with "reload until ... contains", not one reload.
- CloudFront 403 "request could not be satisfied" on review-and-payment and newsletter server-action POSTs (2026-10-07) after heavy runs: cleared by itself within hours. Not test-fixable; wait and rerun.
- Live ERP data drifts: product 310239 had 0 stock everywhere and Invoices went empty (2026-10-07), both recovered within hours. Check stock/account state before blaming tests.
- Branch stock changes between page loads and can't be set in admin: scenarios pick "first enabled Select This Branch" rather than a named branch.
- Basket groups lines into "Collect at Branch X", "Delivery" and courier sections; one collection branch per basket. Mixed order checkout: sign-in -> click-and-collect -> delivery -> billing -> review -> Opayo.
- Basket is per browser session, not per account: a fresh login starts empty.
- Checkout totals are ex VAT; Opayo charges inc VAT. VAT toggle is site-wide, so scenarios switch it back.
- Opayo sandbox: declined card = any non-test PAN; a wrong CV2 is NOT declined.
- Creating a wishlist redirects to its page (no toast); rename needs a reload to show.
- PLP has two "Clear all" buttons: use the `[role=dialog]` one while the filter drawer is open.
- `/sitemap` returns 413 to curl (too large uncompressed) but loads in a browser; `/sitemaps/*.xml` only exist on prod.
- Ask a question / profile email use JS validation, not native `required`/`type`.

## Coverage and gaps
- Covered: guest delivery and logged-in C&C real orders (`@places-real-order`), pay on account, payment decline, basket shipping/C&C, PDP rules (min qty, multiples, timber lengths, multibuy), promotions, wishlists incl. share, account (profile, addresses, invoices, orders), branch finder, header/footer, search, mobile drawer, account application validation (step 1).
- Built from QA manual exports JTDOVE-2026-10-22.json (144 cases) and JTDOVE-2026-10-23.json (22 smoke cases).
- Not automated: Limit Total Uses (suspected defect); self-build application validation (button may be the final submit); self-registration (doesn't exist on JT Dove).
- Stale manual cases: no Local Branch on profile (139), no Download Catalogue/Warranty messages in header (21, 24).
- Gaps (2026-10-22 review): mobile viewport beyond the drawer, logged-in delivery checkout, full account applications. Guest C&C is covered by the mixed-basket checkout (2026-10-23).

## Tips for extending
- Staging footer has a "QA Smoke Test Page" link (absent on prod) if you need a test page.
- Promotions are easiest via the admin API (`staging-api.jtdove.pub`, bearer token from an admin login): amounts and `basket.subtotal` are in pence; PATCH is 405 (PUT the full GET body); `uses`/`emailUses` read-only; incompatibility is `promotionCompatibilities: [{"incompatiblePromotion": "/promotions/<id>"}]` (a plain IRI 500s).
- Record any new fixture (id/code) here as "do not delete".
- Scenarios that place orders need `@places-real-order` + `I require staging for this scenario`.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
