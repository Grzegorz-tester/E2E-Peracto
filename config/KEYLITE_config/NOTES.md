# KEYLITE automation notes

Keylite Roof Windows storefront (Peracto/Carbon-based Next.js, like MIPA): roof windows sold through a "Build & Buy" configurator, plus blinds that fit an existing window. Runs `src/features/KEYLITE_features/`. Admin is a separate project (`config/KEYLITE_ADMIN_config/NOTES.md`).

## Environments
- `env/KEYLITE_STAGING.env` -> `https://staging.keyliteroofwindows.pub/` (staging, free rein: real Braintree sandbox orders, registrations, agreed form submissions).
- `env/KEYLITE_RELEASE.env` -> `https://2-1-0.keyliteroofwindows.pub/` (release, treated as staging). The numbered host bumps per sprint: update `LOGIN_URL`/`GUEST_URL`/`LOGIN_SUCCESS_URL` and `hosts.json` `release_branch` together.
- No production env exists for Keylite (as of 2026-10-24).
- `LOGIN_SUCCESS_URL` is `/account`, not `/`.

## Test accounts and data
- User types (`users.json`): `logged in`, `guest`.
- No `KEYLITE_LOGGED_IN_*` vars in `.env`; `PROJECT=keylite` falls back to the generic `LOGGED_IN_EMAIL`/`LOGGED_IN_PASSWORD`. Each release branch has its own seeded database, so an account valid on one branch may not exist on the next.
- The logged-in account has real past orders (flat read-only table, no per-row detail page) and a saved address book.
- Promo `20SKI2025`: real Keylite "Engineer Discount" (admin Promotions id 39), 20% off, manual entry, Blind sub-type products ONLY (a window basket gets "The promo code conditions have not been met."). Do not delete. If retired, pick another active manual-entry Engineer Discount code rather than creating a promotion.
- Blinds serial `1100160000014` (window code 04A, 780mm x 780mm, confirmed 2026-09-06). Real serials come from Peracto Admin > Products > Size Finder (`/size-finder`). If it stops resolving, pull a fresh row from there; never guess. `0000000000000` is the deliberate negative-path serial.
- Payment: Braintree Drop-in (sandbox). Plain 4111 Visa stalls on a 3DS challenge iframe; use the "Visa 3DS frictionless" test card (`payment-test-cards.ts`), which goes straight to `/checkout/thank-you`. Orders carry a "Velstar Test" delivery note.
- Leftover: staging order W000540 stuck in Pending from an abandoned 3DS-challenge probe (2026-09-23). W000541 was the first real automated order.
- Contact form: Peracto Admin > Forms id 13 ("Contact Query") emails Keylite staff even on staging; the test uses "Velstar Test" data and a "please ignore" message, consent unticked.
- Test PDP: ray.lux Flat Glass with Kerb (pdp.feature); blinds via `blackout-blinds`.

## Known site defects (expected red)
- Account address book "Add new address": server action returns 200 with body `{"data":{"error":"An error has occurred. Please try again."}}` for a valid payload (confirmed 2026-09-06, RE-CONFIRMED 2026-09-23). Scenario scaled back to read-only. Do not re-attempt add/edit/delete there until Keylite fixes it.
- Same form mangles postcodes before sending ("SW1A 2AA" sent as "SW 1 A 2 AA").
- Checkout accepts "NOTAPOSTCODE" as a UK delivery postcode (open question for Keylite, deliberately not asserted either way).

## Quirks and gotchas
- Keylite silently no-ops real (even forced) mouse clicks far more than any other project. PDP configurator controls sit under a sticky gallery panel, so a click lands on the gallery chevron. Use `I click on the "Nth" "X" element via JavaScript` and treat every new Keylite click as suspect. Exception: basket controls (qty +/-, remove, promo Apply) take normal clicks.
- Add to Basket (PDP quick-select) starts disabled even though a default lozenge looks selected; click a lozenge first. The headline "From £..." price never changes; the price that tracks options is the separate "Total:" figure.
- Every add-to-basket is a Next.js server action (POST to the PDP URL with a `next-action` header). Use "I wait for the basket update to complete" before going to `/basket`; networkidle resolves instantly and is not a "write finished" signal.
- ray.lux product data changed by 2026-11-11 (staging and 2-1-0 alike): the Build & Buy wizard has a 5th step, Operating Kit (Size > Opening Operation > Kerb Type > Operating Kit > Review), and the PDP shows Kerb Type above Opening Operation, whose options are now Electric Opening / Fixed / Manual Opening (Electric Remote/Switch gone). Use "PDP selected opening operation" for the opening group's selected value.
- Configurator (windows and blinds share one component: `group-0-option-N`, `__next-step`, `__add-to-basket`). Blinds Step 1 serial input loads behind a spinner; advancing right after filling can no-op once, so use the "via JavaScript, retrying until the X is displayed" step (Next is the same persistent element every step, so never blind double-click). On the Review step the price testid changes to `product-configurator__product-review--product-price`. The "configurator options" selector is scoped to `button[...]` (it used to match 4 elements per option).
- 2-1-0 (2026-11-11): Review & Pay has a required "I have read and understood the delivery, offloading and handling requirements" checkbox (Radix `button[role=checkbox]#delivery-consent__handling-acknowledgement`, saved as `basket.handlingAcknowledged`). Without it, Pay now shows a red validation message and the Braintree Drop-in never loads (looked like a payment outage). Both purchase journeys tick it with the "retrying until it is checked" step.
- PDP (2-1-0): picking an opening variant (Manual/Electric Opening) shows a REQUIRED "Do you need an operating kit?" radio list; until one is chosen Add to basket stays enabled but adds nothing (red "Please choose an operating kit..." message). The PDP total is now `product-order-summary__total` (amount in the first span). Use "operating kit none option" ("No, I already have one") for a single-line basket.
- Add to basket with a kit is a chain of server actions (window, then child kit line); "I wait for the basket update to complete" now waits for the chain to go quiet (2026-11-11), not just the first response.
- The configurator's Operating Kit choice (e.g. Operating Rod 1.5m, +£38.40) is added as a SEPARATE child basket line, so the window line alone is below the Review price; compare the basket subtotal instead.
- Guest checkout: the delivery address form resets ~500ms after first render; settle before filling. County must be filled even though it is not marked required. Logged-in delivery page has a second section (Phone + delivery method + second Continue) on the same URL; logged-in billing reuses the saved-address picker.
- Mailchimp newsletter popup (`[id^="mcforms-"]`) blocks clicks and its close button is never Playwright-visible headless; "I dismiss the newsletter popup if present" removes it from the DOM.
- 2026-11-11: the same Mailchimp popup now carries a full-height "BLACK FRIDAY" creative plus a bottom-left "UP TO 30% OFF" tab, and slides in ~10s after load (after the one-off dismiss has run), covering basket qty/promo, "Continue as Guest" and the header search dropdown. Both storefront envs now set `BLOCK_REQUEST_HOSTS=chimpstatic.com mailchimp.com`, which removes it entirely (confirmed live, no page errors). The footer newsletter form is first-party (server action), unaffected.
- `/account` pages render a stripped header (logo only); go "home" before header checks.
- Submit buttons (profile Save Changes etc.) are dirty-state gated; the profile form renders two copies of Save Changes (`nth=0` in `account-profile.json`).
- `qa-<timestamp>` markers typed into name fields get reformatted; put markers in Address Line 1 instead.
- Header search goes to `/search?q=`; the generic path step URL-encodes the `?`.
- RETRACTED (2026-09-23): logged-in checkout "Continue never advances" was a test gap (missed the Phone/delivery-method section), not a site bug.

## Coverage and gaps
- 53 scenarios, 53/53 on staging and release (2026-09-23/24): home, header, menu draw, footer, sitemap, search, PLP, PDP, window configurator, blinds configurator, basket + basket interactions (promo), guest and logged-in purchase journeys (real orders, `@places-real-order`), checkout validation, register (creates a real account each run, keep to one scenario), login, reset password, my account, branch finder, replace my window, contact us + newsletter (real submissions, `@submits-real-form`, agreed 2026-09-24).
- Not covered: navigating from a menu drawer link (links have `href=""`), the replacement enquiry form submission (presence only), the "Use product size" blinds path (only "Use serial code"), postcode validation, non-default delivery methods (staging has only "GB shipping service: FREE").
- 2026-11-22 dedupe: basket.feature deleted (covered by basket-interactions' remove scenario, which now carries @smoke) and the all-1st-options Build & Buy scenario removed (subset of the priced-options one). 55 -> 53. Contact-us presence check kept: the full submit is @submits-real-form.

## Tips for extending
- Assume any new configurator product reuses the same `product-configurator` component before exploring from scratch.
- Default to the JS-dispatch click; pair it with an "if present" second attempt when it still no-ops.
- Any new real form submission emails Keylite staff or feeds their Mailchimp: agree it with Keylite via the account manager first and tag `@submits-real-form`.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
- 2026-11-23 smoke run on staging after the redundancy cut: 4/4 including the moved @smoke "Removing the only item empties the basket"; login passed on retry.
