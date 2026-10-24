# WATCO automation notes

Watco UK storefront (watco.co.uk), the reference market for 8 Watco storefronts. Search/listing is Bloomreach-driven, card payments go through Adyen, PDP reviews are a Feefo widget. Runs `src/features/WATCO_features/` (UK VAT suite + UK-only PDP extras) plus the shared `src/features/WATCO_SHARED_features/`.

This file also holds the knowledge shared by every market (see "Shared across all Watco markets" below). Market files (`config/WATCO_<REGION>_config/NOTES.md`) only add market-specific facts.

## Shared across all Watco markets

### Shared suite (`src/features/WATCO_SHARED_features/`)
- Built 2026-09-06/07 and wired into every market's staging AND prod `FEATURE_PATH` (alongside that market's own VAT folder). 12 files, 24 scenarios: address-book, basket (3), change-password, forgotten-password, home, login (2), order-history, pdp (3), plp-browse-filter-sort (6), quote (2), search (2), vat-toggle.
- Edit only the shared `.feature` files for golden-path behaviour; never copy them into a market folder. Market differences live purely in each market's `config/WATCO_<REGION>_config/` (routes, translated mappings).
- Design rules that keep it market-agnostic: no locale text in Gherkin; positional keys ("first category link", "second brand filter checkbox"); sort chosen by ordinal ("3rd" = Price Low to High on staging-uk's order: Most Popular, High-Low, Low-High, A-Z, Z-A), so each market's dropdown order must be re-verified; address-book scopes to its own typed marker "Velstar Test Automation Address" and always deletes it again.
- Search term "epoxy" is relied on by pdp/basket/quote and the VAT suites in every market. basket.feature's two-product scenario also searches "mixing stick" (English): not confirmed to return a result on non-English markets.
- Scenarios added 2026-09-09 (vat-toggle, both search scenarios, quote, pdp colour swatch + reviews) were only confirmed on staging-uk. Their element keys ("Ex VAT toggle", "search results heading", "colour option swatches", "reviews section", "Add to quote", quote keys) and the `quote-list`/`quote-detail` pages exist ONLY in `WATCO_config` as of 2026-10-24, so expect them to fail on the other 7 markets until mapped (inferred from config, not a live run).

### Known site defects (all markets)
- PLP price sort is genuinely broken in both directions (confirmed 2026-09-09 on staging-uk AND watco.co.uk prod, client ticket raised). The two "Sorting by price" scenarios are EXPECTED RED until Watco fixes it. Don't re-scope selectors hunting another false positive; check the ticket first. Lead (unverified): the sort uses a cached/default price rather than the displayed "From" price.
- Product links in search results and PLP "View product" cards are absolute URLs to an internal Bloomreach content host that doesn't resolve publicly (confirmed on staging). Use `I click on the "X" link via its href on this origin`, which rewrites the host.

### Quirks and gotchas (all markets)
- RETRACTED: "PLP sort/filter/pagination broken on prod" (2026-09-09). Prod `/floors` has a static Bestsellers block above the real grid using the same `.card-fresh` component; unscoped selectors read its never-changing first card. A ticket had already gone to the client before this was caught. UK `plp.json` keys are scoped to `#results-container`; sibling markets still use bare `.card-fresh` (staging has no Bestsellers block, so it is a no-op there, but check any prod "first card" assertion).
- "Update basket" form action is untranslated `/basket/update` on every market, even where the basket page route is translated. Fixed 2026-09-07 in BENL/NL/FR/DE/PL/BEFR mappings.
- `added-to-basket` route must be each market's real translated route (FR/DE/PL/BEFR had the English placeholder until 2026-09-07).
- Basket "Update" button stays disabled until the quantity value changes; clicking it earlier (even forced) is a silent no-op. Wait for enabled.
- Native `confirm()` dialogs are auto-dismissed by Playwright; use `..., accepting the confirmation dialog` for JS-confirm deletes (address book).
- The cookie preference-centre overlay reappears mid-scenario and swallows `force: true` clicks. Every significant click carries `, removing the "cookie preference centre overlay" overlay if it interferes`; the `dismissing ... if it interferes` variant was needed on PL. A missing clause on "Save details" caused the 2026-09-07 account-profile failure.
- Marketing-agreement `<label>` wraps a long paragraph: needs a precise (non-forced) click.
- "Enter address manually" link's handler binds late; use the `retrying until the ... appears` click, never a blind double-click (it toggles).
- Ex VAT / Inc VAT toggle is a full-page `/toggle-tax/...` link; both labels are always in the DOM, one hidden via `d-none`, so text checks can't see the state.
- Zero-results search still renders a "you might like" carousel with `.card-fresh` cards; assert the "Products (0)" tab / "Viewing 0 of 0" count instead.
- Filtering, sorting and paginating are full navigations and the page size hides count changes; assertions compare the first card title before/after.
- PDP colour options are custom `<div>` swatches (`.product-configurable__swatch`, "current" class), not native inputs.
- Login: the generic `I am navigating the page as a "X" user` flow times out on Watco; log in through the form steps (as quote.feature does). Only `WATCO_STAGING.env` sets `LOGIN_URL`/`LOGIN_SUCCESS_URL`.
- RETRACTED (WAT-305): "account profile Save details doesn't persist VAT". Real cause: Company, Job function and Industry sector are required on the profile form but never collected at registration, so native HTML5 validation silently blocks the submit. Confirmed 2026-08-26 on every market; scenarios fill them first. Same lesson as other Peracto forms: check required fields before calling it a site bug.
- Express checkout never offers Pay on Account on any market (asserted by localised name where relevant).
- Prod registration has reCAPTCHA ("The form ReCaptcha has failed", 2026-08-26), hence `@completes-registration` is excluded on prod.

### Accounts, data and safety (all markets)
- User types (every `users.json`): "account test user 1", "account test user with vat", "guest". Credentials come from `.env` as `<PROJECT>_ACCOUNT_TEST_USER_1_EMAIL/_PASSWORD` and `<PROJECT>_ACCOUNT_TEST_USER_WITH_VAT_EMAIL/_PASSWORD`, where `<PROJECT>` is the env's `PROJECT=` slug upper-cased (e.g. `WATCO_DE`, `WATCO_DE_PROD`).
- Credentials history: all Watco vars were lost in the 2026-09-16 `.env` wipe and restored 2026-10-22; login check that day passed 28/32. Still invalid (as of 2026-10-22, need new passwords from the user): `ACCOUNT_TEST_USER_1` for BEFR, BENL, FR and NL PROD. Note: the 2026-10-20 audit note saying "no Watco credentials locally" predates the restore and is stale.
- "account test user with vat" is a shared, mutated account (basket and saved address persist). `logged-in-checkout-vat-persistence.feature` places TWO real Pay on Account (Adyen card on PL) orders per run on staging and expects the account to start at its VAT baseline; an interrupted run leaves it dirty and the next run fails loudly. Baseline values are in each market file's docblock.
- Order history needs a verified email; order-history.feature deliberately uses "account test user 1". On prod the order list is empty (no real orders allowed), so `@requires-order-history` is excluded there.
- change-password only exercises mismatch validation; forgotten-password only requests a reset. Never complete either: it would break the shared account everywhere.
- `account-profile-vat-save.feature` and the registration success scenario register a new throwaway account each run (accounts accumulate; known leak per the 2026-10-20 audit).
- Quote clean-up: the logged-in quote scenario deletes its own quote (UK, live-verified 2026-10-22, account at zero quotes). On prod it would create and delete a quote on the test user's account; the other 7 markets fail before creating anything.
- Prod (`*_PROD.env`): no orders, no registration, no real form submissions. Excluded tags: `@places-real-order`, `@completes-registration`, `@requires-order-history`; persistence scenarios also call `Given I require staging for this scenario`. As of 2026-09-07 the shared suite was wired on prod but not yet run there; UK prod was exercised for the PLP investigation on 2026-09-09.
- Watco admin: intentionally NOT covered (user, 2026-08-25: "watco is actually slightly different"). Platform never probed; if it comes up, ask what the admin runs on rather than guessing a Peracto host.

### Onboarding a new Watco market
PLP category-slug regex, translated routes and mapping text, brand-filter/sort ordinal check, "Update basket" form action, real `added-to-basket` route, and whether "account test user 1" is email-verified (order history). Then add the UK-only keys listed above if those scenarios should pass.

## Environments
- `env/WATCO_STAGING.env` -> https://staging-uk.watco.pub (staging, free rein; slug `watco`).
- `env/WATCO_PROD.env` -> https://www.watco.co.uk (production, read-only rules; slug `watco_prod`).
- Header comments in the `*_PROD.env` files describe the older "UI_AUTOMATION_HOST=production only" exclusion; the gate now also triggers on the `_PROD` suffix (see CLAUDE.md).

## Test accounts and data
- `WATCO_ACCOUNT_TEST_USER_1_*`, `WATCO_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod). All working at the 2026-10-22 check.
- "account test user 1" is email-verified on staging-uk and has real past orders, so order-history runs. "account test user with vat" is NOT verified (can't view order history).
- UK registration requires email verification (unlike FR/BE-FR).

## Known site defects (expected red)
- PLP price sort (shared, above).

## Quirks and gotchas
- UK guest Pay on Account enforces a £500 minimum (new-customer minimum-order notice is UK and IE only). Pay on Account is always offered regardless of VAT.
- VAT validation accepts the XI (Northern Ireland) prefix and rejects a too-long GB number.
- Real Adyen/3DS card completion and Apple/Google Pay sheets are not automated (Chromium has no ApplePaySession). No email-reading infrastructure.
- Only UK has the Bestsellers-scoped `#results-container` PLP keys and the quote/search/vat-toggle/pdp-extra mappings.
- Stale comment: `logged-in-checkout-vat-persistence.feature` still calls profile "Save details" a confirmed bug; superseded by the WAT-305 retraction.

## Coverage and gaps
- Staging 28/28 on 2026-09-07 (before the 2026-09-09 shared additions). No full-run result recorded since.
- UK-only: `pdp-datasheet-and-cross-sell.feature`, pinned to "Watco Epoxy Matt Coat" because tabs/cross-sell are per-product CMS content (the "epoxy" search result has neither).
- Not covered: order confirmation VAT display via real card, confirmation emails, admin.

## Tips for extending
- Add new golden-path scenarios to `WATCO_SHARED_features` and map their keys in all 8 configs, not just UK.
- Pin product-specific content (data sheets, cross-sell) per market only after confirming an equivalent SKU.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
