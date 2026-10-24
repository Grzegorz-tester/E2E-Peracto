# INSINKERATOR_EU automation notes

InSinkErator EU multi-market storefront (Peracto, locale-prefixed routes such as `/en-gb`, `/de`). Runs `src/features/INSINKERATOR_EU_features/`, ported from the P3Playwright repo's `insinkerator_eu` tests. The UK suite (`INSINKERATOR_features`) was ported from this one. The ISE Service Portal is a separate project.

## Environments
- `env/INSINKERATOR_EU_STAGING.env` -> `https://staging.insinkerator-eu.work/` (staging, free rein: real CyberSource test-mode orders and registrations OK).
- No production env or production host in `hosts.json` (as of 2026-10-24). `hosts.json` also has an empty `release_branch` and `dev` (`localhost:3001`).
- Admin site is a separate project: `INSINKERATOR_EU_ADMIN`.

## Test accounts and data
- User types (`users.json`): `logged in`, `guest`.
- Credentials: `INSINKERATOR_EU_LOGGED_IN_EMAIL` / `INSINKERATOR_EU_LOGGED_IN_PASSWORD` (`PROJECT=insinkerator_eu`). Restored 2026-10-22 after the `.env` wipe; login needs "Accept cookies" dismissed first.
- The logged-in account (`accountTestUser_1` in the source suite) is SHARED by every logged-in scenario: change-password sets the password to itself on purpose.
- Promo code `PROMO10` -> promotion "Automation QA Test Promo", success message "Promotion PROMO10 is now applied". Set up on staging for automation (2026-09-05); do not delete.
- Payment: the `default` CyberSource test card works here (unlike UK, which needs `mastercard`).
- Markets: Portugal = ecommerce-enabled (`hasEcom: true`, used almost everywhere); Poland = non-ecommerce ("Where to buy" gating). Poland was briefly switched to full ecommerce on 2026-09-05 by the business, then reverted; the gating assertions are correct again.
- Known-simple purchase product: sink flange (`/products/sink-flange-oil-rubbed-bronze`). `standard-460` is a configurable bundle (configurator + PDP content).
- Warranty finder registers a fresh product each run (no fixture to protect). Product registration covers the EU domain only (UK form out of scope, INSE-764).

## Known site defects (expected red)
- Accessories PLP "Price NaN €": filtered to "Air Switch" + sorted price low-to-high + after Load More, every price renders "Price NaN €" (3/3 repros, confirmed 2026-09-05). The sort step fails with a "prices were: [...]" diagnostic on purpose.
- Configurator price mismatch: PDP-advertised delta for an extra (e.g. Extended Sink Flange, +€53.10 in basket) differed from the basket by about €4.90 (flagged 2026-09-05, not root-caused, VAT/discount suspected). The feature file comment still describes only a ~1 cent rounding tolerance; that comment and the ±0.5 tolerance need revisiting.
- Poland non-ecommerce PDP: "Where to buy" button is DISABLED on every attempt, modal unreachable (still current at the source suite's last check). Asserted as today's behaviour.
- Client-side click from the Shop PLP to `standard-460` leaves the PLP grid rendered although the URL changed (SPA rendering bug, confirmed 2026-08-15). Tests navigate to the sink flange instead.
- Accessories PLP: Load More stops updating the count while the Filter & Sort drawer is open (confirmed 2026-08-15). Close the drawer via its own Close button first.
- Sitemap "locations" has one stale entry that returns HTTP 200 with a client-rendered "404 - We couldn't find the page" (verified 2026-08-15); asserted via rendered content, not status.
- Promo form applies ANY code with no validation, no error, no request (as of 2026-09-05). No invalid-code scenario until real validation exists.

## Quirks and gotchas
- Every fresh page load shows a mandatory "Choose your country" modal: dismiss with "Accept cookies" then "Select Portugal" (or Poland) if present. Mid-session switching via the utility bar is covered separately.
- Country-selector buttons intermittently vanish or become unclickable under heavy run volume (suspected rate limiting, unconfirmed, 2026-09-05). Usually passes on the 2nd or 3rd attempt.
- WAF: staging intermittently serves "Your request has been blocked for security reasons", e.g. on direct navigation to `/login` (my-account.feature). The AfterStep hook reports it as "BLOCKED BY SITE FIREWALL". Worse under heavy volume. Allowlisting the runner needs the account manager.
- Cookie banner (OneTrust) reappears mid-session and swallows `force: true` clicks and checks (Secure Checkout never leaving `/basket`; "same as delivery" Radix checkbox not toggling 6 times in a row). Use the non-forced `..., dismissing the "X" if it interferes` click and check steps; the check variant was added for this site.
- Timeouts: `SCRIPT_TIMEOUT=20000` is low. Steps with their own polling ("if present", address autocomplete, dismiss-check) carry explicit 45000-60000ms overrides; budget for one extra loop iteration.
- Promo UI changed 2026-08-15: `add-promotion-form__button` only opens the field; a separate "Apply" button submits.
- Algolia PLP: changing sort legitimately resets Load More pagination (e.g. 22 -> 11); the step waits for the count to settle.
- Basket extras: the "Additional Services" upsell reuses the extras testids; selectors count only ticked rows (`aria-checked="true"`), fixed 2026-10-12 for UK and EU.
- Accessories: `/our-accessories` is a landing page; its "Shop" CTA reaches `/category/accessories`. The header "Shop" link goes to `/category/shop`. "Our Accessories" expands to a tier-2 "View All" in the nav drawer.
- Search drawer close needs a real mousedown-pause-mouseup gesture.
- Comparatively stable site when not WAF-blocked (contrast HIB).

## Coverage and gaps
- 16 feature files: health check, logging in, my account, basket (incl. PROMO10), guest + logged-in purchase, accessories PLP, PDP content, configurator, mid-session country switch, Poland non-ecommerce journey, product registration, warranty finder, search drawer, sitemap redirects, footer newsletter.
- Purchase journeys, product registration and the newsletter submit are NOT tagged `@places-real-order` / `@completes-registration` / `@submits-real-form`. Harmless while there is no EU prod env; tag them before adding one.
- No production env, no release env.

## Tips for extending
- Every Background needs the cookie + country dismissal; pick Portugal unless testing gating.
- Use dismiss-aware, non-forced clicks anywhere in basket/checkout.
- Keep failing loudly on real site bugs (NaN prices) rather than tolerating them.
- Fixes here usually apply to UK too (shared testids); check `config/INSINKERATOR_config/NOTES.md`.
- The 2026-09-05 fixes were also written up for porting to a sibling plain-Playwright repo (memory note `project_insinkerator_eu_2026-09-05_fixes`).

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
