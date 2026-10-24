# PIZZAEXPRESSLIVE automation notes

PizzaExpress Live: live-music venue and events storefront (Next.js, page data references `api.pizzaexpresslive.com`). Ticketing, basket and account all live inside a third-party Spektrix iframe (`bookings.pizzaexpresslive.com`). Runs `src/features/PIZZAEXPRESSLIVE_features/`. Admin is a separate project (`config/PIZZAEXPRESSLIVE_ADMIN_config/NOTES.md`).

## Environments
- `env/PIZZAEXPRESSLIVE_PROD.env` -> `https://www.pizzaexpresslive.com/` (PRODUCTION, the only storefront env). Strictly read-only: no bookings, no purchases, no form submissions. Renamed from the unsuffixed `PizzaExpressLive.env` on 2026-10-19, which had quietly been pointing at production.
- No storefront staging env exists (as of 2026-10-24); `hosts.json` has only `production`.

## Running
- Scenarios are tagged `@PizzaExpressLive_regression`, NOT `@regression`. Use the dedicated profile: `COMMON_CONFIG_FILE=env/PIZZAEXPRESSLIVE_PROD.env ./run_tests.sh PizzaExpressLive_regression`. The plain `regression` profile selects nothing here.
- Being a production run, the profile still filters `PRODUCTION_UNSAFE_TAGS`.

## Test accounts and data
- `users.json` defines `logged in`; `.env` has `PIZZAEXPRESSLIVE_LOGGED_IN_*`, but it is UNUSED: there is no native login page (login lives inside the Spektrix iframe), so no scenario logs in. `LOGIN_URL`/`LOGIN_SUCCESS_URL` point at `/account` as placeholders.
- No fixed event fixtures: events come and go. Scenarios use "I open the first 'event card link' element whose 'X' is present on the destination page" to find a suitable live event (Book Tickets table, Book Now, Join waiting list, Contact box office).
- Venues: the header Venues dropdown lists only Soho, Holborn, Chelsea; the Venues page lists Soho, Holborn, Chelsea and Piano Lounge (Leicester Square). Covent Garden has a page but is in neither (confirmed 2026-08-20).

## Known site defects / behaviour (expected)
- Spektrix's widget script on `bookings.pizzaexpresslive.com` 403s on every page (harmless, outside the site's control). The console-error scenario ignores "Failed to load resource" wholesale because Chromium's message never includes the URL.
- Mobile header has no basket icon (only the hamburger drawer does), so it is not asserted.
- Sold-out or past-cutoff events render with no `#event-dates` section at all, hence the "first card whose X is present" step rather than "1st event card".

## Quirks and gotchas
- Spektrix iframe is behind Cloudflare bot protection: driving it headless is blocked (confirmed 2026-08-20). All booking/basket/account scenarios stop at "the right iframe loads with the right src".
- A permanent, undismissable "outdated browser" banner is fixed at the top of every page (both viewports) and intercepts header clicks. A one-shot removal is not enough (it reappears); use "I permanently remove the 'outdated browser banner' overlay for this scenario" before header/menu clicks.
- What's On filters: the first listbox option is the "All Venues"/"All Months" placeholder, so pick "Soho" or "2nd". Assert on text, not counts (the listing keeps a constant ~120-node DOM). Grid and List share `results wrapper`; Calendar has its own `calendar view` and no `results wrapper`.
- Coming Soon carousel: all slides are already in the DOM, so "next" is proven by the prev arrow becoming enabled, not by text change.
- Console-error ignore list: mailerlite, googletagmanager, spotify, Spektrix bookings, Didomi, X-Frame-Options, "Failed to load resource".

## Coverage and gaps
- Covered (5 files): page rendering (home, carousel, What's On, venues, CMS pages, PDP), filters/views/search, navigation + Spektrix basket/account iframes + footer + mobile nav, `__NEXT_DATA__` API checks (event slug/sku/prices/attributes/availability, image 200), Spektrix booking (choose-seats iframe; waiting list and box office forms filled until Submit Enquiry enables, never submitted because it emails the venue box office).
- Not covered: anything inside Spektrix (seats, login, checkout, payment). Revisit only if a non-headless or session-based Spektrix strategy is agreed.
- Gap: no staging storefront, so nothing transactional can ever be automated here as things stand.

## Tips for extending
- Tag new scenarios `@PizzaExpressLive_regression`.
- Strip the outdated-browser banner first in any scenario that clicks near the top of the page.
- Do not hard-code event names or months; they go stale.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
