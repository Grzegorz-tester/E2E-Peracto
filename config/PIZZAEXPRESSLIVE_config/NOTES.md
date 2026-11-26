# PIZZAEXPRESSLIVE automation notes

PizzaExpress Live: live-music venue and events storefront (Next.js, page data references `api.pizzaexpresslive.com`). Ticketing, basket and account all live inside a third-party Spektrix iframe (`bookings.pizzaexpresslive.com`). Runs `src/features/PIZZAEXPRESSLIVE_features/`. Admin is a separate project (`config/PIZZAEXPRESSLIVE_ADMIN_config/NOTES.md`).

## Environments
- `env/PIZZAEXPRESSLIVE_PROD.env` -> `https://www.pizzaexpresslive.com/` (PRODUCTION, the only storefront env). Strictly read-only: no bookings, no purchases, no form submissions. Renamed from the unsuffixed `PizzaExpressLive.env` on 2026-10-19, which had quietly been pointing at production.
- `env/PIZZAEXPRESSLIVE_STAGING.env` -> `https://staging.pizzaexpresslive.pub/` (staging, added 2026-11-13 for PE-76, the Peracto 79 / Symfony 7.4 / PHP 8.4 upgrade). Talks to `staging-api.pizzaexpresslive.pub`; Spektrix iframe is `bookings.pizzaexpresslive.pub` (production uses `.com` for both). Same Cloudflare block on the Spektrix iframe as production.
- Env-specific content: the API base URL check is split into a `@production-only` and a `@not-on-production` scenario; Spektrix iframe assertions check only the `/pizzaexpress/website/...` path so they pass on both.

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
- Staging baseline 2026-11-13: 32/35. The 3 reds are staging DATA, not test or site bugs: (1) search for "jazz" returns no results on staging (other terms do; staging search index or event data is thinner than prod, worth watching for PE-76's SPX-04); (2) Coming Soon carousel has too few items to scroll, both arrows disabled; (3) no staging event currently has a Contact box office button (nor does production as of 2026-11-13: 0 of the first 25 events, so this one is red on BOTH envs until such an event exists). Expected to go green once staging gets the prod data copy planned for PE-76; re-check then before changing the tests.
- PE-76 gap scenarios (tag `@PE-76`, built 2026-11-13): `api-contracts.feature` (health, 401 without token, refresh endpoint, error format, hydra collection shape), `error-pages.feature` (404 status + page), `sitemap.feature`, `similar-events.feature` (staging-only fixture event with relations). API steps resolve against `API_BASE_URL` in the env file. Staging 18/19, production 17/18 (similar events is `@not-on-production`).
- Known defect, pre-existing on BOTH envs (not PE-76): `/sitemaps/products.xml` lists events as `/products/<slug>`, which 404; events live at `/whats-on/<slug>`. Expected red in sitemap.feature. Sitemaps also serve `content-type: application/x-www-form-urlencoded` rather than XML (not asserted).
- PE-76 watch item: the API returns `hydra:member`/`hydra:totalItems`; API Platform 4 drops the `hydra:` prefix by default. The menus shape scenario is the canary.
- Staging allows form submissions, so the PE-76 validation-error checks (API-03, PHP-05) can be built here, never on production.

- Time-of-day effect (CONFIRMED 2026-11-13): late in the evening the first What's On events are that night's shows, past cutoff with no dates (`childEvents` empty, no `#event-dates`). The "first event card whose X is present" step now dedupes links ignoring `#event-dates` and has a 90s budget; before that, an evening run failed 7 scenarios that pass in the morning.
- 2026-11-22 dedupe: removed the view-toggle outline (venue/month outlines open every view), membership/faqs CMS rows and 3 of 4 footer rows. Staging 54 -> 46, prod 53 -> 45 (PizzaExpressLive_regression profile).

## Tips for extending
- Tag new scenarios `@PizzaExpressLive_regression`.
- Strip the outdated-browser banner first in any scenario that clicks near the top of the page.
- Do not hard-code event names or months; they go stale.

_Last reviewed: 2026-11-13. Sources: memory notes + feature file comments._
