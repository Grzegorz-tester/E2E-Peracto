# ANDY_THORNTON automation notes

Andy Thornton storefront (contract/hospitality furniture; moodboards act as quotes), a Peracto storefront with Opayo/Elavon hosted card payment. Runs `src/features/ANDY_THORNTON_features/` (21 feature files, roughly 100+ scenarios). Admin is a separate project: see `config/ANDY_THORNTON_ADMIN_config/NOTES.md`.

## Environments
- `env/ANDY_THORNTON_STAGING.env` -> `staging.andythornton.pub`. Free rein: real orders (guest and logged-in), registrations, moodboard CRUD.
- `env/ANDY_THORNTON_PROD.env` -> `www.andythornton.com`. No real orders (`@places-real-order`), no registration (`@completes-registration`), no moodboard writes (`@not-on-production`). Editing the test user's own profile/address book is allowed and restored. `BLOCK_REQUEST_HOSTS=cookiebot.com cookiebot.eu` (the Cookiebot banner blocks clicks on prod).
- No storefront release env (`release_branch` in hosts.json is empty). `at-17x-peracto.andythornton.pub` URLs are the ADMIN release branch, not the storefront; this mix-up has happened twice. Don't infer storefront vs admin from an AT URL's name.
- Prod differences use `@production-only` / `@not-on-production` rows (home sections, `/services`, staging-only `/best-hospitality-furniture-2024`).

## Test accounts and data
- users.json types: `logged in`, `non admin`, `guest`, `admin` (features use the first three).
- Staging: `ANDY_THORNTON_LOGGED_IN_EMAIL`/`_PASSWORD` and `ANDY_THORNTON_NON_ADMIN_EMAIL`/`_PASSWORD` (non admin is a separate plus-aliased account). Prod: `ANDY_THORNTON_PROD_LOGGED_IN_*` and `ANDY_THORNTON_PROD_NON_ADMIN_*`. Without them the run falls back to generic `LOGGED_IN_*` (the HIB account) and fails "Invalid credentials".
- The `logged in` account is an admin-type user: it has no Moodboards. Moodboards need `non admin`.
- The logged-in account is SHARED with other people (their addresses and ~15 moodboards). Only create/delete uniquely named Velstar data; put back anything edited. Its only saved address belongs to another user, so logged-in orders are marked "Velstar Test" in the delivery notes.
- If a contiguous block of logins fails, check whether someone changed the shared password mid-run (happened 2026-09-30, also hit the admin run).
- Moodboard test data: every board named "Velstar Test Moodboard <timestamp>"; Background sweeps leftovers with that prefix only.
- Staging promotion fixture: promotion id 78 "Velstar Test 1% Off", code `VELSTARTEST1`, unlimited uses, staging admin only. Backs basket.feature's valid-promo scenario (£122.40 -> £121.17, discount rounds UP). Do not delete. If it fails "not a valid promo code", check promotion 78 is still Active.
- Prod account: 0 orders (order history tagged `@requires-order-history`), addresses "Bob Smith" plus a pre-existing "Velstar Test" address not created by these runs; leave both.
- Registration on staging creates a real `qa-<ts>@velstar-test.co.uk` account each run (known small data leak, 4 accumulated as of 2026-10-20).
- Staging's cheapest dining chair (£0.99) looks like a placeholder product; not asserted on.

## Known site defects (expected red)
- Prod Profile page broken: `/account/profile` lands back on the `/account` Dashboard with no form. my-account "Profile elements" and account-actions "Saving the profile" stay red. Raised with the site owner 2026-09-14, still live 2026-09-30. Works on staging.
- Prod price sort low-to-high misorders multi-variant products ("From £72.00" after £78.00). Confirmed 2026-09-30; staging page 1 had no such card.
- Moodboards list shows only the 15 newest with no pagination (likely UX bug, staging 2026-09-30); new boards still appear as newest.
- Prod reset password: reCAPTCHA shows "Invalid domain for site key" under Playwright and the success message never appears, while a real browser succeeds. Expected red under automation, not a site misconfiguration (as of 2026-09-14).

## Quirks and gotchas
- Cloudflare on prod (from 2026-10-01): "Verify you are human" challenges and intermittent "500 Application Error" pages to the headless runner. 13 scenarios passed only on retry, and guest checkout's "delivery address can't be used" scenario went red. Not test-fixable (bypassing it is detection evasion); needs a Cloudflare allowlist from AT via the account manager. Don't "fix" with waits; stop re-running prod while challenged.
- Prod rate-limits fast crawls: HTTP 429 after ~10 quick page loads (2026-09-30). health-check.feature can trip it; don't crawl prod.
- Hydration races, each fixed with a settle: basket +/- buttons (no-op for ~3s after render), "Add new address" (prod), signed-in checkout Continue (retried), and Add to basket then immediate basket navigation (can land on an empty basket).
- Clicking "Checkout" does not redirect instantly; checkout.feature's Background confirms the redirect before acting.
- Guest checkout Billing: ticking "Same as delivery address" swaps the form for a summary with its own Continue ("billing continue" key). The delivery form keeps "Use this address" disabled until first/last name, line 1, city and postcode are filled (no error text).
- Delivery is priced by postcode (£144.00 saved address vs £158.40 for NW1 6XE); compare to the review step's own total, never a hard-coded amount.
- Payment uses Opayo/Elavon's published sandbox test card on a hosted redirect page (no iframe step needed).
- Moodboards = quotes: the PDP pin icon (no label/testid; `[data-testid=product-add-to-basket] button:not([data-testid])`) opens "Add to Quote", which pre-selects the newest board. "Create a new quote" needs Quote Name + Customer Name + Reference (CREATE is styled not-allowed rather than disabled). Builder delete reads "Delete Moodboard", list delete reads "Delete"; delete confirmation has no dialog role. Removing an item has no confirmation. Prod account menu shows "Quotes" where staging shows "Moodboards".
- Home page has no semantic `<h1>` (hero is a styled CMS block); the check uses "header logo". Prod and staging home sections differ completely.
- `/services` redirects to home on both envs. Some pages have content but no heading, so their text is checked instead. A missing page returns a real 404 (link checks are meaningful, unlike HIB).
- PDP accordion renders twice (desktop + hidden mobile), so mappings use `:visible`. The heading step uses `.first()` because some pages repeat their heading.
- Search uses `?q=` (not `?query=`). Only `/pub-furniture` has a product grid; Hotel, Café, Bar and Restaurant are content-only.
- Profile save shows "User successfully updated" (`account-profile__alert`); wait for it before reloading.
- Register: button disabled until required fields are filled; password and duplicate-email errors appear only on submit.
- The wrong-password login row must use a REGISTERED email; an unregistered alias gets "Username could not be found." instead of "Invalid credentials.".
- Contact enquiry and newsletter forms email or subscribe real AT staff/lists: never submitted with valid data on any env (only browser validation is tested).

## Coverage and gaps
- Covered: health check (header/menu/footer links), home, header, PLP/category PLP (Contract Furniture sub-categories, venues, price order, pagination), products filter/sort, PDP and PDP content/navigation, search results, basket incl. promo, guest + logged-in checkout with real payment (staging), login/reset password, registration, my account, account actions (profile, address book, orders), moodboards/quotes CRUD, articles, contact us and newsletter validation.
- Not covered: valid contact/newsletter submissions (deliberately), confirmation emails, anything on prod that writes beyond the user's own profile/addresses.
- Andy Thornton was flagged by the user as "an old project we will rework" (2026-08-25); check whether the storefront moves platform before large investment.

## Tips for extending
- Tag real transactions (`@places-real-order`, `@completes-registration`) or mark data as `@not-on-production`; prod shares this `FEATURE_PATH`. customer-flow.feature once lacked its tag and would have paid on prod.
- Treat first-attempt prod failures with Cloudflare/500 screenshots as environment noise until an allowlist exists.
- Prefer uniquely prefixed test data plus a prefix sweep (`I delete every "rows" whose "name" starts with ...`) because the account is shared.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
