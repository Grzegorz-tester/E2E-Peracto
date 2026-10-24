# INDESPENSION automation notes

Indespension storefront (trailers, trailer parts, towbars and towbar fitting bookings, branch finder), a Next.js Peracto storefront. Runs `src/features/INDESPENSION_features/` (16 feature files). Admin is a separate project: see `config/INDESPENSION_ADMIN_config/NOTES.md`.

## Environments
- `env/INDESPENSION_STAGING.env` -> `staging.indespension.pub`. Free rein: real orders (Pay on Account), real towbar bookings, registrations, contact and newsletter submits.
- `env/INDESPENSION_RELEASE.env` -> `release_branch` in hosts.json, `next-15.indespension.pub` (Next.js 15 upgrade branch). Treated as staging (real orders OK, per user, 2026-08-28). As of 2026-09-29 the host returned a TLS error and may be retired; confirm it is up before using. When the branch changes, update `release_branch` in hosts.json and the three URLs in the env file together.
- `env/INDESPENSION_PROD.env` -> `indespension.co.uk`. No real orders, bookings or form submits. Every real-submission click uses `I click on the "X" button as the final real submission` (Place order / Pay now, Confirm Your Booking, Register, Contact submit, newsletter submit): on prod it asserts the button is visible and enabled, then the scenario shows as skipped. All 6 journeys reached their gate on prod without submitting (2026-09-29).
- Prod blocks Cookiebot for the whole run (`BLOCK_REQUEST_HOSTS=cookiebot.com cookiebot.eu`); the banner blocked clicks on every prod page and accepting it per scenario was unreliable.
- Environment-specific rows use `@production-only` / `@not-on-production` (branch finder, header/menu drawer items).
- `dev` host in hosts.json is `http://localhost:3001` (no env file uses it).

## Test accounts and data
- users.json types: `logged in`, `guest`, `admin` (storefront features only use `logged in` and `guest`).
- Staging and release env files have no `PROJECT=` line, so they log in with the generic `LOGGED_IN_EMAIL`/`LOGGED_IN_PASSWORD` fallback. Prod uses `PROJECT=indespension_prod` -> `INDESPENSION_PROD_LOGGED_IN_EMAIL`/`_PASSWORD` (also `INDESPENSION_PROD_ADMIN_*` defined, unused by these features).
- The staging `logged in` account is a trade/credit customer: checkout reaches "Pay on Account" with a mandatory PO Number, no card gateway. The prod account is NOT a credit account: Review shows "Pay now" with no PO field, so the PO fill is "if present" (confirmed 2026-09-29).
- The logged-in basket is server-side and persists across runs; logged-in-purchase-journey clears it first. Basket scenarios use guest sessions for a guaranteed empty basket.
- Register uses a unique guest email per run. Checkout test data uses "Velstar Test" as the name.
- Towbar test path: search a real vehicle (FORD/VOLKSWAGEN/BMW/TOYOTA/NISSAN/PEUGEOT all cascade); "AKFS" and "AL-KO" are component brands with no Model/Year data (correct, not a bug).

## Known site defects (expected red)
- Branch finder, staging: Google Maps rejects the staging domain (`RefererNotAllowedMapError`). The map draws after ~10s, then Google swaps it for "Oops! Something went wrong" (`.gm-err-container`), and town-search autocomplete never suggests. Two scenarios red (map load, town search) until the staging domain is added to the Maps API key's referrers. Confirmed 2026-09-29. Branch finder was 6/8 then.
- Guest card checkout (`checkout.feature`), staging: GlobalPayments hosted fields validate fine but submit returns "Payment Error: no gateway available" before the card is evaluated. Staging gateway config gap, kept red on purpose. As of 2026-08-21; not re-verified since.
- Towbar vehicle search: the page's marketing copy describes a 5-step VRM journey with no discoverable entry point; manual cases for VRM search do not exist on the site. Flagged for a developer, as of 2026-08-21.

## Quirks and gotchas
- Next.js hydration race is the number one cause of failures here. Submitting the login form before hydration does a native GET (`/login?email=..&password=..`) and reloads with fields wiped. Same race on register, newsletter, contact-us, Add to Basket and Pay on Account. Fix: `I wait for the page to settle` after navigation (already in every affected Background). Screenshot shows wiped fields or a greyed submit button -> suspect hydration first.
- Prod: an early "Menu" click can be swallowed before the header hydrates, so the menu steps retry until the drawer is open. Same for the footer sitemap click and the Billing Continue (retry until Review loads).
- Overlays: the added-to-basket dialog's fade-out overlay and the menu drawer backdrop intercept forced clicks. Use `I click precisely` (non-forced) for the header Basket link and menu links (confirmed via `elementFromPoint`, 2026-08-27).
- Menu drawer selectors are scoped to the open drawer by text. The `navigation-drawer-sheet__link-N` testids belong to the desktop header bar behind the backdrop, and N shifts with the item list. Staging drawer has Offers (opens a sub-tier needing "View All") and Services (a sub-menu button, not a link); prod has News instead. Careers on both.
- Towbar booking (lesson worth reading in `towbar-fitting-booking.feature`): slots render visible but disabled for ~1-1.5s while availability loads. The old single `isEnabled()` check reported "no slots" for weeks; polling fixed it (85%+ real availability). It was never inventory exhaustion. Other towbar facts:
  - Must be reached via the real vehicle search; direct URL to a towbar PDP shows "may not be compatible" and the date widget never renders.
  - Both variant tabs render a full copy of the widget, so mappings use `:visible`.
  - Pick the LAST week option (nearest week can be cutoff-blocked). The last Radix Select option was never "stable" under the auto-scroll edge; keyboard fallback in `selectOptionWithEnabledCandidate` (form.ts).
  - "Continue to Booking" must be clicked precisely (forced click fires before the disabled -> enabled re-render).
  - Prod requires a wiring kit selection first ("if present"; does not add to basket). Staging has no picker.
- Vehicle search fields are Radix comboboxes: use `I select the "X" option from the "Y" listbox`, not the native dropdown step.
- Used Trailers PLP: click "Sort By" only after settling, or Algolia background calls close the dropdown.
- Header: VAT toggle only renders for guests. "Download Catalogue" goes to `/catalogues`. Some redirects are just slow (use the "eventually" step, up to 30s).
- Login lands on `/account` (a dashboard layout with no hamburger menu), not home.
- Sitemap: only on the stripped footer of CMS pages (start from contact). Each category is its own `/sitemap/{category}` route; the item selector is an XPath anchored on the "Sitemap" h1. Cloudflare 503s on hover prefetch are ignored by link-navigation.ts.
- Branch finder search input lost its react-google-places id; matched by placeholder. "View all branches" scrolls correctly but never adds `#all-branches` to the URL (asserted with `should be scrolled into view`). Prod branch search is geocode-submit, not Places autocomplete.
- Firewall: the storefront WAF ("Your request has been blocked for security reasons") trips on full-suite volume and lifts within minutes to ~1.5h. Header/home/login failures in a full run with that page in the screenshot are environmental. Allowlisting needs the account manager.
- A one-off prod 500 on branch search (2026-09-29) did not reproduce in 4 attempts.

## Coverage and gaps
- Covered: login/reset password, register, my account (4 tabs: Dashboard, Profile, Address Book, Orders), header, menu drawer, home, footer newsletter, contact us, sitemap, Used Trailers sort, basket (guest), guest card checkout, logged-in Pay on Account journey, towbar vehicle search and full fitting booking, branch finder.
- Not covered: "Cash" payment flow (needs a second, non-credit test account, flagged for a human decision); declined-card cases (blocked by the gateway gap); confirmation emails; wiring-kit finder (no live equivalent on staging); PLP facets (none on Used Trailers).
- As of 2026-09-29, the real-submission journeys (logged-in purchase, checkout, towbar booking, register, contact, newsletter) had not been re-run on staging after the prod gate was added.

## Tips for extending
- Older HIB copy-paste was purged during the 2026-08 rebuild; check any unfamiliar key against the live site, not HIB.
- Name files after the Insinkerator convention (`basket-interactions`, `logged-in-purchase-journey`, `shop-plp`...).
- Any new real submission must use the "as the final real submission" click so prod stays safe without excluding the whole scenario.
- Settle after navigation before the first interaction on any new page.
- Real booking/order scenarios create real staging records each run; don't re-run them needlessly.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
