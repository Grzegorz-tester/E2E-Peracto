# BENCHMARX automation notes

Benchmarx Kitchens & Joinery storefront (Travis Perkins brand, Peracto on Next.js, Algolia search, Acuity-backed consultation booking, no basket or checkout). Runs `src/features/BENCHMARX_features/` (7 features, 24 scenarios, built 2026-10-24 from the QA smoke export `BEN-2026-10-24.json`). Admin is a separate project: see `config/BENCHMARX_ADMIN_config/NOTES.md`.

## Environments
- `env/BENCHMARX_STAGING.env` -> https://staging.benchmarx.pub. Free rein, BUT see "Consultation booking" below: the booking form talks to real branch calendars.
- No release or production env yet (as of 2026-10-24). Production is www.benchmarxkitchens.co.uk; if one is added, all CLAUDE.md production rules apply.
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
- Not covered: BEN-120, BEN-122/123/124 (see above), brochure request, contact us, newsletter, trade sign-in.

_Last reviewed: 2026-10-24._
