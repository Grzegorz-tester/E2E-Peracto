# BENCHMARX automation notes

Benchmarx Kitchens & Joinery storefront (Travis Perkins brand, Peracto on Next.js, Algolia search, Acuity-backed consultation booking, no basket or checkout). Runs `src/features/BENCHMARX_features/` (7 features, 24 scenarios, built 2026-10-24 from the QA smoke export `BEN-2026-10-24.json`). Admin is a separate project: see `config/BENCHMARX_ADMIN_config/NOTES.md`.

## Environments
- `env/BENCHMARX_STAGING.env` -> https://staging.benchmarx.pub. Free rein, BUT see "Consultation booking" below: the booking form talks to real branch calendars.
- `env/BENCHMARX_RELEASE.env` -> https://3-6-0.benchmarx.pub since 2026-11-23 (was https://next-15.benchmarx.pub, added 2026-11-11 for BEN-379, the Next.js 15.5.28 / React 19 / Node 24 upgrade; the next-15 sections below refer to that host). Treated as staging. Expected behaviour is always "same as staging": run both and compare.
- No production env yet. Production is www.benchmarxkitchens.co.uk; if one is added, all CLAUDE.md production rules apply.
- `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=25000`. No cookie banner seen on staging, so no `BLOCK_REQUEST_HOSTS`.

## Test accounts and data
- Every scenario runs as a guest. `users.json` only defines `guest`; trade sign-in exists (`/trade-customers/Sign-in-or-register`) but isn't covered.
- Fixed fixtures: PDP `/kitchens/nordica-blue-true-handleless` (3 gallery images), search term "Soho Gloss White" (exactly 1 result), branch "Leeds" (LS11 0EY). If one disappears, re-pick from `/sitemaps/products.xml`.
- Booking contact details use "Velstar" / "Test", a unique email and a unique mobile number.

## Consultation booking (DO NOT CONFIRM)
- `/book-a-consultation` is 4 steps: branch (nearest 3 to a typed town), type (Online / In-branch), date + time, then "One last thing..." with contact details and CONFIRM BOOKING.
- Staging availability comes from `/api/acuity/availabilityDates|availabilityTimes` with REAL branch calendar ids. Confirming would book a real designer slot and email the branch, so `book-a-consultation.feature` stops with CONFIRM BOOKING visible and enabled. Get a test calendar or test branch before automating the confirm step or Qase BEN-122/123/124 (email, cancel, reschedule), which all start from a real booking.
- BEN-120 (branches that show the "Book a free design appointment" form instead of Acuity) isn't automated: which branches do this isn't exposed in any response we could find. Needs a branch name from QA.

## Known site defects (expected red)
- Search by SKU finds nothing (e.g. `05-soho-gloss-white`, the product's real sku). `search.feature` "Searching by SKU finds the product". The search page has shown both "Sorry, we can't find any results for ..." and, in framework runs, an unfiltered "All Products (156)" with the search box emptied. Unconfirmed whether kitchen SKUs are meant to be searchable; ask QA (2026-10-24).
- Header search shows default suggestions before Algolia answers for the typed term: wait for a matching suggestion before reading it.
- Ashford (the QA case's own example) has no bookable dates: Acuity returns `invalid_calendar` ("calendar 4707161 does not belong to appointment type 23814535"). Not asserted; the scenario uses Leeds instead (2026-10-24).
- Branch finder: searching before the Google Maps script loads (within about 1s of landing) crashes the page into a "500 Application Error" (`window.google.maps.Geocoder is not a constructor`). The scenario settles first, so it isn't red; worth raising (2026-10-24).
- Not asserted: the customer kitchens modal ignores Escape (X and backdrop click work). The QA case describes three consultation types; staging offers two.

## Quirks and gotchas
- Hydration: clicks on the PLP filter button, pagination, PDP thumbnails and the booking form do nothing if made straight after landing. Use "I wait for the page to settle" first.
- The PDP renders a desktop and a mobile copy of everything: mappings use `>> visible=true`.
- The PLP filter tick can land mid drawer animation: use "I check ..., retrying until it is checked".
- PDP thumbnail highlight does NOT move when a thumbnail is clicked; the main image's `alt` does, so that's what's asserted.
- The customer kitchens modal has no role/testid: mappings anchor on its "Browse by style" heading. "Click outside" uses the generic `I click outside the "X"` step (added 2026-10-24).
- Booking testids: the branch options carry `radio-select_option-[object Object]` (site bug, harmless); "Show branches" is title case in the DOM, upper case only via CSS.
- No sitemap index file: `/sitemaps/sitemap.xml` returns `{"error":"Not Found"}` on staging and production. Production's robots.txt lists `/sitemaps/<type>.xml` (products, categories, content, articles, locations, plus image/article-category ones); `sitemap.feature` samples those via the generic XML sitemap step. Staging robots.txt is `Disallow: /`.

## Coverage and gaps
- Covered (Qase): BEN-98 PDP, BEN-101/103/104 PLP, BEN-105 search, BEN-109 branch finder, BEN-116 sitemaps, BEN-117/118/119 customer kitchens, BEN-121 booking up to confirm.
- Admin cases BEN-110 to BEN-115 are covered by the shared admin suite (see the admin notes), except the "verify on the storefront" halves, which need a cross-site step.
- Not covered: BEN-120, BEN-122/123/124 (see above).

## BEN-379 Next.js 15 regression suite (added 2026-11-11)
- Test plan IDs are referenced in each scenario's comment (GL, NAV, HP, PLP, PDP, ACC, SRCH, BR, BK, FRM, CNT, SEO, RES). Run the same suite on `BENCHMARX_STAGING` and `BENCHMARX_RELEASE`; a scenario green on staging and red on the release env is a regression.
- New features: `global-layout`, `navigation`, `homepage`, `accessories-and-joinery`, `branch-pages`, `forms`, `content-pages`, `seo-and-status-codes`, `responsive-layout`; additions at the bottom of `shop-plp`, `pdp-content-and-navigation`, `search`, `branch-finder`, `book-a-consultation`.
- New generic steps in `src/step-definitions/base-steps/assertions/verify-page-state.ts`: path status code (no redirects followed, catches soft 404s), response body contains, page title, head tag non-empty / canonical matches current path, JSON-LD parses, browser Back, full-reload detection (client-side routing), page scroll lock, alphabetical sort order, no horizontal scroll.
- `pages.json` ends with a catch-all `content` page (`^/.+$`) so `common.json` keys resolve on any CMS page. Keep it LAST: page IDs match in file order.
- Cross-browser (XB-01): `UI_AUTOMATION_BROWSER=webkit` (or `firefox`) runs the same suite.
- Still manual (not automatable here or needs sign-off first): GL-03 cookie banner (none on staging), GL-06/GL-07 visual checks, PDP-03 Read more (not found on the fixture PDP), PDP-04 lightbox, BK-02 geolocation (permissions are denied by the framework), BK-06 real booking (real Acuity calendars), FRM-05 offline, TRK-*, CCH-*, PERF-*, A11Y-01, ENV-01.

## next-15 regressions found 2026-11-11 (staging 209/212, next-15 152/212)
Each is green on staging and red on next-15; re-verified by hand where noted.
- R1 search ignores ?q= ("All Products (141)"): 12 search scenarios.
- R2 branch pages fall over to the Peracto 500 page after load: 12 scenarios. Console shows `TypeError: s.findDOMNode is not a function` (removed in React 19, likely a map/transition library) as well as the server action error. Also makes the mobile branch page 410px wide.
- R3 branch finder never renders (spinner): 8 scenarios plus the mobile layout one.
- B1 booking step 1 lists no branches (Maps key RefererNotAllowedMapError): 4 scenarios.
- R4 customer kitchens modal: "Failed to load kitchen details", no Get this look cards.
- R5 blog `?page=2` ignored, page 1 shown again (verified by hand).
- R6 header links do a full document reload instead of client-side navigation (verified by hand: staging soft-navigates once hydrated, next-15 never does).
- R7 soft 404: `/kitchens/does-not-exist` returns 200 (staging 404). Also hides the stale-Algolia PLP links below, which is why PLP-01 is green on next-15.
- R8 every template logs "An unexpected response was received from the server." (a failing server action site-wide): all 15 console-baseline scenarios and 4 search-input ones.
- R9 newsletter sign-up: the server action fires with the email but the form never shows "Thanks for subscribing" (staging does). Confirmed 2026-11-12, 3 runs out of 3.

## Known staging defects found 2026-11-11 (pre-existing, not BEN-379)
- Algolia lists kitchens whose PDPs 404 (`/kitchens/eton-gloss-cream-true-handleless`, `/kitchens/eton-matt-white-true-handleless`): PLP-01 link check is red on both envs until the index is rebuilt.
- `/privacy-notice` (footer) is a 404 on staging and live; excluded from the footer link mapping.
- PDP console error `Cannot read properties of undefined (reading 'pointtype')`; ignored in the console baseline.
- Booking step 4 accepts a phone number of "123".
- Older articles hardcode absolute live links that 404 on live (e.g. `/article/blog/introducing-our-new-benchmarx-design`). Only relative links are checked.
- Trustpilot answers automated requests with 403; only first-party USP links are requested.
- Staging pages sometimes sit on a loading spinner for 10s+ under parallel load; content scenarios wait up to 30s for the content block.
- Header search: pressing Enter before Algolia answers for the typed term submits an empty query. Wait for a suggestion containing the term first.

_Last reviewed: 2026-11-11._

## Real form submissions (2026-11-12)
- Agreed with the user: contact, trade FAQ and contract kitchen enquiries and newsletter sign-ups from staging and next-15 land in the TEST Peracto admin (`staging-api.benchmarx.pub/form-submissions`), not with real branches. `forms.feature` submits them, tagged `@submits-real-form` (never runs on production).
- Test data is always explicit: name "Velstar Test", `qa-<timestamp>@velstar-test.co.uk`, phone 01234567890, postcode LS1 1AA, message "Velstar Test - automated QA submission (BEN-379), please ignore."
- Success: enquiry forms redirect to `/contact-us/thank-you` (contact and trade FAQ) or `/contract-kitchen-solutions/thank-you` with "Thank you for your enquiry"; the newsletter replaces the form with "Thanks for subscribing".
- Wait for the page to settle before submitting the newsletter: before hydration it submits natively as `/?email=...&customerType=homeowner` and nothing is saved.
- Bookings are still not confirmed: Acuity calendars are real.

## next-15 redeploy, run of 2026-11-18 (169/216)
- Fixed since 2026-11-12: R1 search, R2 branch pages render (React 19 crash gone), R3 branch finder renders, R4 customer kitchens, R5 blog page 2, R6 client-side navigation, R8 server action error, R9 newsletter.
- Still open: R7 soft 404 on /kitchens/does-not-exist. B1 Maps key (RefererNotAllowedMapError) now also breaks the branch page map, the branch finder search (the places input loses its #react-google-places-autocomplete-input id) and booking's location search.
- New on next-15: R10 the PLP sort has lost "Name A-Z" and "Name Z-A" (staging has 5 options, next-15 has 3). R11 the PLP shows 16 cards per page (staging 15): possibly deliberate, confirm with dev. C1 CookieYes logs "Looks like your website URL has changed" on every page (the CookieYes site is registered for staging's URL only; config, like B1); this is now the only console-baseline failure.
- "Clear all filters" failed once with the button detached mid-click: re-render race, not counted as a bug.
- CookieYes is now on staging too, so GL-03 (cookie banner) could be automated.

## next-15 run of 2026-11-19 (175/216)
- Fixed since 2026-11-18: R10 (name sort options back), R11 (15 cards per page again).
- Still open: B1 Maps key (branch page maps, branch finder map and search, booking location: 16 scenarios), C1 CookieYes registered URL warning (20 console scenarios), R7 soft 404 (2).
- NEW R12, confirmed by hand 2026-11-19: closing the PLP filter drawer drops the applied filter. Staging keeps 62 results, the chip and "Clear all"; next-15 goes back to 137 with no chip within 1s. The "Clear all filters" scenario fails on it; "Removing a filter chip" passes on next-15 only because the count is already back to unfiltered (a false pass while R12 is open). The 2026-11-18 "Clear all" failure was this too, not a re-render race.

## next-15 run of 2026-11-22 (176/216)
- Same open defects as 2026-11-19: B1 Maps key (RefererNotAllowedMapError: branch page maps, branch finder map and search, booking location, 17 scenarios), C1 CookieYes registered URL (20 console scenarios: 15 templates + 5 search edge cases), R7 soft 404 (2), plus the long-standing SKU search miss (1).
- R12 FIXED, verified live 2026-11-22: closing the drawer keeps the filter (62 results and chip held for 3s, 5 of 5 tries on next-15, same as staging). The "Clear all filters" first-attempt failure was a test race: while the drawer closes, two "Clear all" buttons are briefly visible and the click hit the one being removed (count stayed 62). shop-plp.feature now waits for the drawer to close and the page to settle first; passes first attempt on next-15 and staging.
- No new failures.
- 2026-11-22 redundancy cut, at the user's request (keep only scenarios testing genuinely different parts): 216 -> 161 scenarios. Same template checked repeatedly was reduced to one: branch pages 10 -> 1 (Leeds), content pages 14 -> 2 (ideas and inspiration, why choose us), trade landing/sign-in 2 -> 1, articles 5 + 3 link checks -> 1 merged, accessories landing 2 -> 1, subcategories 7 -> 2, detail pages 3 -> 1, homepage Browse buttons 4 -> 1 (Shaker, now also does PLP-07's range landing checks; shop-plp PLP-07 six-range outline removed), PDP per range 4 -> 1, BR-06 "Find a branch from 3 pages" removed (GL-01 and NAV-06 cover it), seo 404 rows for unknown page/kitchen/branch removed (own scenarios in content-pages, pdp, branch-pages), branch page console check removed (GL-05 branch row). Changed scenarios verified on staging 11/11. Kept on purpose: per-template console/SEO/responsive rows, search edge cases, sitemaps, form submissions, sort options. Expected next-15 counts now: B1 8, R7 1.

## next-15 run of 2026-11-23 (131/161, first full run after the redundancy cut)
- All 30 failures are known, no new ones and no retried passes: B1 Maps key (8: booking location 4, branch finder 3, branch page map marker 1), C1 CookieYes registered URL (20: 15 templates + 5 search edge cases; branch finder and branch templates also log the Maps error), R7 soft 404 (1), SKU search miss (1).

## 3-6-0 first smoke run, 2026-11-23 (smoke 31/56; staging same day 49/56)
- Release env repointed from next-15 to https://3-6-0.benchmarx.pub. Both smoke runs went to scratch report folders, so `reports/BENCHMARX_RELEASE/` still holds the last next-15 run.
- Red on both (known, not 3-6-0 issues): SKU search miss (1), CookieYes registered-URL console warning (5 search edge cases; now on staging too), `/kitchens/eton-gloss-cream-true-handleless` and `/kitchens/eton-matt-white-true-handleless` 404 from the All kitchens listing (stale Algolia records, 1).
- 3-6-0 only, verified by hand against staging:
  - S1 search ignores ?q=: `/search?q=oak` shows "All Products (142)", staging "Showing results for oak (9)". 9 search scenarios. Same symptom as R1 on next-15.
  - S2 `/branches` stays on `loading-spinner` forever (staging renders the finder and the A to Z list): 5 branch finder scenarios, and the booking form's branch options never appear either (4 booking scenarios). Same symptom as R3 on next-15.
  - S3 customer kitchens modal shows "Failed to load kitchen details": no description and no "Get this look" cards (staging has both). 1 scenario, 3 of 3 runs.
- Probable, 2 of 3 runs: removing the PLP filter chip leaves the count filtered (62, not 137). Looks like R12 back again; confirm by hand before reporting it.
- Console on 3-6-0 also logs "Failed to fetch RSC payload ... Falling back to browser navigation" for header/footer links (link prefetch failing). Staging doesn't. Not asserted by any smoke scenario.

## 3-6-0 first full regression, 2026-11-25 (115/161, no retried passes)
- Known, not 3-6-0 issues (1 + 20): stale Algolia links from the All kitchens listing (1); CookieYes registered-URL console warning (20: 15 templates + 5 search edge cases; the branch template also logs the Maps RefererNotAllowedMapError).
- S1 search ignores ?q= (8 search scenarios, includes the long-standing SKU miss). S2 `/branches` never renders (branch finder 5, booking branch options 4, mobile branch finder 1). S3 customer kitchens modal (1). B1 Maps key: branch page map marker (1).
- NEW on 3-6-0, not in the 2026-11-23 smoke:
  - S4 blog `?page=2` ignored, page 1 shown again (2 scenarios). Verified by curl 2026-11-25: staging page 2 starts "What is the 26 feet rule?", 3-6-0 page 2 repeats page 1 ("Carpenters use Benchmarx to transform old barn"). Same symptom as R5 on next-15.
  - Header links do a full page reload instead of client-side navigation (1). Matches the "Failed to fetch RSC payload ... Falling back to browser navigation" console message seen in the smoke run. Same symptom as R6 on next-15. Not yet verified by hand.
  - Newsletter never shows "Thanks for subscribing" (1, one run). Same symptom as R9 on next-15. Not yet verified by hand.
  - Branch page `branch__enlarge-map` link missing entirely (1). It was present on next-15 despite B1, so not just the Maps key. Not yet verified by hand.
- The PLP filter chip / R12 suspicion from the smoke run did not reproduce: all shop-plp filter scenarios passed.
