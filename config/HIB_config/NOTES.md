# HIB automation notes

HIB bathroom furniture/lighting storefront (Peracto, Next.js front end, B2B "portal" basket for logged-in trade users, guest browsing with a GBP/EUR currency picker). Runs `src/features/HIB_features/`. The admin site is a separate project (`config/HIB_ADMIN_config/NOTES.md`).

**NEVER PLACE A REAL HIB ORDER, ON ANY ENVIRONMENT (staging, release or production).** This is a CLAUDE.md rule and the user restated it on 2026-09-29 for staging too. Every purchase-path scenario stops before the final PLACE ORDER (`[data-testid='proceed-to-payment']` on finalise-order). Do not add a scenario that clicks it, not even behind `@places-real-order`.

## Environments
- `env/HIB_STAGING.env` -> `https://staging.hib.pub` (backend `staging-api.hib.pub`). Free rein except orders (see above). `SCRIPT_TIMEOUT=35000`.
- `env/HIB_RELEASE.env` -> `https://feature-hib-170.hib.pub` (backend `hib-170-api.hib.pub`), treated as staging. Moved here 2026-09-28 from the dead `release-2-0-0.hib.pub`; the user supplies new release URLs. Update the 3 URL literals in the env file AND `hosts.json` `release_branch` together. First request after idle can take ~14s (cold start).
- `env/HIB_PROD.env` -> `https://www.hib.co.uk`, added 2026-10-15. Strictly read-only: no basket adds, no forms, no profile edits. Sets `BLOCK_REQUEST_HOSTS=cookieyes.com`.
- `hosts.json` also has `dev` (`http://localhost:3001`).
- Any `*.hib.pub` subdomain that no longer exists fails with `ERR_SSL_VERSION_OR_CIPHER_MISMATCH`. On HIB that means "host is gone", not a broken certificate.
- Staging and release use DIFFERENT backends but behaved identically on every point checked on 2026-09-28, so a failure on both is usually a stale test, not a feature-branch regression.

## Test accounts and data
- User types (`users.json`): `logged in`, `guest`.
- Credentials: staging/release (`PROJECT=hib`) read `HIB_LOGGED_IN_EMAIL`/`_PASSWORD`; prod (`PROJECT=hib_prod`) reads `HIB_PROD_LOGGED_IN_*` (same login as staging per the user, 2026-10-15). Verified working 2026-10-22 after the `.env` restore.
- The account is a B2B portal account: address book is read-only from the storefront (the "add address" links render empty), it has NO orders (`/users-orders` returns none), and logged-in users never see the currency picker (confirmed correct, 2026-09-29).
- Each login creates a fresh server-side basket (`POST /baskets` 201), so basket lines do not carry over between runs.
- Delivery address: if checkout/address scenarios fail on a missing `address-0`, check `/account/address-book` first. On 2026-10-14 the staging account had lost its delivery address (billing ones intact); it was re-added via HIB staging admin (Users > All Users > test user > Add New Address, Delivery, first name "Velstar Test").
- Staging data created via admin on 2026-10-14 to make storefront pages work, do not delete: article category 8 "Blog" (path `blog`, backs `/articles/blog`), and the re-linked Customer Feedback form (form 10, fields re-linked via `PUT /forms/10`, email flags left OFF).
- Test products: "Vanquish" search on place-order (first hit was the £749 cabinet as of 2026-09-28, with a 10% "Total discount" line), Solas PDP (`solas` page id, currency + customer-flow), SKU 47600 (Vanquish 50 cabinet, `vanquish-cabinet`), `vanquish-trim` (the "You may also need" View Options link). Auryn `AUCROBK` is gone (Page Not Found).
- Find a Retailer uses postcode `SW1A 1AA`.

## Known site defects (expected red)
- Release (feature-hib-170), as of 2026-09-29, all fine on production: `/specifiers-developers` client-side crash, `/articles/blog` 404, Customer Feedback form renders only Submit (form 10 has 0 field links on `hib-170-api` vs 9 on prod: release data drift). `enquiry-forms.feature` and `health-check.feature` comments mark these KNOWN RED. Staging's equivalents were fixed via admin on 2026-10-14.
- Release find-a-retailer: "Application error", React minified error #525 once locations load (3/3, 2026-09-29), ticket raised by the user. On 2026-10-14 the same symptom on STAGING was retracted as a site defect (it traced to the staging API 500s below). Re-check the release before assuming either way.
- Staging API (`staging-api.hib.pub`, shared with HIB_ADMIN staging) intermittently 500s with a PHP "Narrowing occurred during type inference of ZEND_FETCH_DIM_W" warning on `POST /auth`, `POST /baskets`, `PUT /baskets/{id}` (confirmed 2026-10-14). Symptoms: login timeouts, Add to basket leaving the Variants drawer open with nothing added, `PUT /baskets/null`. Server config (PHP OPcache/JIT), not test-fixable; reported to the user for the account manager. Check API responses for this 500 before touching waits or selectors.
- Production: find-a-retailer crashes ("window.google.maps.Geocoder is not a constructor") if you search before Google Maps loads (6/6 immediate, 0/8 after ~8s, 2026-10-15). Minor real race; the test settles first.
- Profile Save cannot work headless on staging or release: `POST /api/recaptcha` scores headless Chromium 0.1 and the update is silently dropped (2026-09-29). Needs reCAPTCHA test keys from HIB's devs. Not automated.
- `/samples` (header "Request Swatch Sample" icon) has only a heading and no content, on production too. Open question for HIB, not asserted as a bug.
- Category pages show exactly 39 cards with no pagination/load more even when facet counts are higher (release and production). Not asserted as a bug.

## Quirks and gotchas
- HIB staging is slow and flaky by reputation (user's own words). Much of that "flakiness" is the PHP 500 above. Verify the selector once, retry once or twice, then move on.
- Login form and reset-password form call react-google-recaptcha-v3 `executeRecaptcha()`, which is undefined for a moment after a client-side navigation to `/login` or `/reset-password` ("h is not a function", silently stays put). Use the "retrying until redirected to the account page" / "retrying until the reset password message is displayed" click steps. The compound login step is unaffected (full page load).
- Portal link goes to `/login?to=/account` and lands on `/account`; the redirect can take 16s+, so use "should eventually be redirected".
- PDPs take 4-6.5s even when idle; after search-result navigation the URL changes before the PDP renders. Settle before clicking variants. Add to basket is a silent no-op until the session basket exists (two `POST /baskets`), so assert "should be enabled" before clicking.
- Quick shop search hit: its container is larger than the inner button, so `first search result` in `place-order.json` targets the `button` inside the hit.
- Checkout PO field id is `purchaseOrder` (was `poNumber`). Phone and PO Number are required; CONTINUE simply stays disabled until both are filled.
- HIB serves "Page Not Found" AND client-side crashes with HTTP 200, so the link-checker step cannot catch them. `health-check.feature` renders each page and asserts its heading (DOM text, not CSS-uppercased; category pages have only an `<h2>`).
- Heading text differs by env: staging is literally uppercase in the DOM ("SUPPORT", "SPECIFIERS & DEVELOPERS"), production is title case. Use `@not-on-production` / `@production-only` Examples blocks. `/category/bathroom-fitted-furniture` exists on staging only.
- Production CookieYes banner swallowed forced clicks (PDP variant click opened its Customise modal), hence `BLOCK_REQUEST_HOSTS=cookieyes.com` on prod.
- Logged-in menu drawer: the first Menu click straight after login can land before hydration; use the "retrying until ... appears" click step.
- Footer "Subscribe" link's testid is `account-menu__logout` (copy-paste on HIB's side), so it is matched by text.
- Basket subtotal vs total: quantity checks use the `basket subtotal` key, not `order total price` (which targets the RRP Total).
- Recurring unexplained flake (2026-10-14): after Add to basket in Stock Check & Quick Order the basket line sometimes never appears. Not investigated; likely the API 500.
- RETRACTED: `products.json` storefront mapping was overwritten with the admin products mapping on 2026-09-18 (our bug, restored from git 2026-09-28). If Products hub scenarios all fail at once, diff that file first.

## Coverage and gaps
- Covered: home, header (search by name/SKU, nav), menu draw, footer + newsletter (opens only), health check (~40 page rows), category PLPs, Products hub, PDP content/navigation, swatch samples (navigation only), currency (guest switch; logged-in has no picker), find a retailer, Contact Us + Customer Feedback (render only), login, reset password, my account (profile fields, address book presence, Quick Order, Contact Us, Sign Out), basket, checkout validation, customer flow up to (not including) PLACE ORDER.
- `@not-on-production`: whole of `checkout.feature`, `customer-flow.feature`, the 4 basket add outlines in `basket.feature`, the my-account Quick Order outline.
- Deliberately never submitted: newsletter (MailerLite form UWRyi4 is the SAME live form on release and prod, lands on HIB's real marketing list), Customer Feedback (`sendAdminEmail: true`, emails real HIB staff), PLACE ORDER.
- Gaps: profile save (reCAPTCHA), order history detail (no orders), address book edits (read-only account).

## Tips for extending
- Run against a narrowed path: `COMMON_CONFIG_FILE=env/HIB_STAGING.env FEATURE_PATH=src/features/HIB_features/<file>.feature ./run_tests.sh regression`.
- Every new feature needs a `@regression` tag (basket.feature had none and never ran until 2026-09-29).
- Start guest scenarios with "I dismiss the newsletter popup if present".
- Anything that adds to the basket, edits the account or submits a form gets `@not-on-production`.
- Before creating data in HIB staging admin to fix a storefront gap, search the API first (`/form-fields?label=` etc.): admin lists paginate at 25 and it is easy to create duplicates.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
