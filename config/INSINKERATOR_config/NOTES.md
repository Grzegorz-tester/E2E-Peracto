# INSINKERATOR automation notes

InSinkErator UK storefront (Peracto, single market, no locale prefix, no country modal). Runs `src/features/INSINKERATOR_features/`. Most files were ported from the EU suite (see `config/INSINKERATOR_EU_config/NOTES.md`); its file naming is the repo's reference convention. The ISE Service Portal (`insinkerator-ws.work`) is a separate project with its own notes.

## Environments
- `env/INSINKERATOR_STAGING.env` -> `https://staging.insinkerator.work/` (staging, free rein: real CyberSource test-mode orders, registrations OK).
- `env/INSINKERATOR_PROD.env` -> `https://www.insinkerator.co.uk/` (production: no real orders, registrations or form writes). Also sets `EXCLUDE_TAGS=@blocked-by-production-waf` (warranty-finder.feature).
- `hosts.json` also has an empty `release_branch` and `dev` (`localhost:3001`, used to test the block-page detector).
- Admin site is a separate project: `INSINKERATOR_ADMIN`.

## Test accounts and data
- User types (`users.json`): `logged in`, `guest`.
- No `INSINKERATOR_LOGGED_IN_*` vars exist in `.env` (as of 2026-10-24), so staging falls back to the generic `LOGGED_IN_EMAIL`/`LOGGED_IN_PASSWORD`. Prod has `PROJECT=insinkerator_prod`, so it would read `INSINKERATOR_PROD_LOGGED_IN_*` first (none set), then the generic pair.
- The logged-in account is SHARED by every logged-in scenario: the change-password scenario sets the password to itself on purpose, never change it to something else.
- `@requires-order-history` (Orders page scenario) needs past orders on the account; excluded on prod automatically.
- Payment: use the `mastercard` CyberSource test card. CONFIRMED 2026-08-15: the `default` Visa test card is rejected by the UK merchant account ("error when processing your payment"). EU uses `default` fine.
- Guest checkout names use "Velstar" as the test marker.
- Test products: sink flange (`/products/sink-flange-oil-rubbed-bronze`, the known-simple product used for purchases), `evolution-plus-750-ec` (configurator), 4N1 Touch tap PDP (finish swatches + add-ons), `standard-460` (PDP content/navigation).
- Warranty finder registers a fresh product each run (no pre-seeded record to protect).

## Known site defects (expected red)
- Search drawer records TWO recent-search entries per search (second is blank, links to `/search?q=`). Confirmed 2026-08-19; test sidesteps it by asserting on the first entry only.
- 4N1 Touch tap PDP: clicking an alternate finish intermittently fails to update the Total (staging). Step re-clicks once before failing (`product-configurator.ts`).
- Production: `standard-460` shows "Enquire Now" instead of "Add to basket" (confirmed 2026-09-22). Possibly intentional business content, not confirmed either way; dropped from product-configurator.feature rather than failing.
- Production: warranty-finder page always serves the WAF block page (confirmed 2026-09-22), hence the `@blocked-by-production-waf` exclusion.

## Quirks and gotchas
- WAF blocks: staging AND prod intermittently serve "Your request has been blocked for security reasons" (2026-10-13: 5 random scenarios across 3 runs; also 2026-10-12 warranty-finder, 2026-10-13 pdp-finish). The AfterStep hook (`block-page-detection.ts`) now fails these fast as "BLOCKED BY SITE FIREWALL". Signature before the hook: home "loads" in under 0.5s, "Accept cookies if present" burns 8s, then a 15-20s selector timeout. Several scenarios only passed via `RETRY=1`. Real fix is allowlisting the runner, which must go through the account manager.
- Cookie banner reappears mid-flow and can intercept even `force: true` clicks (confirmed at Secure Checkout, Billing continue, before paying). Use the `..., dismissing the "X" if it interferes` steps on checkout clicks.
- Basket "Additional Services" upsell (from 2026-10-12) reuses the extras testids (`basket-items__available-line-0__extra-options`). Unticked rows were counted, so the total check was off by exactly the upsell price (GBP 180). Selectors now count only ticked rows (`:has(button[aria-checked="true"])`). Lesson: a mismatch equal to an upsell price means an unticked offer was counted, check `aria-checked` first.
- Installation history: until 2026-10-13 the disposer line had its own Installation tick box that appeared not to work. It was NEVER confirmed as a defect (user suspected staging slowness, logging only covered the main host) and the box is now gone. Only the "Food Waste Disposer Installation" card (SKU INHHD) remains; the scenario uses it, matched by "Installation" in the name, and passes.
- UNCONFIRMED, not a raised bug (2026-10-12): basket showed unit price GBP 519.00 but line total GBP 415.20 (exactly 20% less) at qty 1 with no visible promotion. Check with the AM/dev team before calling it a defect.
- Search drawer close needs a real mousedown-pause-mouseup gesture, not a plain click (`search-drawer.ts`).
- PDP carousel prev/next both disabled at a wide viewport is correct (content does not overflow), not a bug.
- Algolia PLP: changing sort legitimately resets "Load More" pagination; the sort step waits for the count to settle.
- Product registration: Place of purchase is required (UI asterisk, disabled submit and backend agree).
- Sitemap categories differ from EU: products, categories, content, articles, article images, product images (no "locations").
- This project's `:text-is("Reset Password")` selectors are the example of why config is not passed via `--world-parameters` (see CLAUDE.md); keep that in mind if editing selector quoting.

## Coverage and gaps
- 15 feature files: health check, logging in, my account, basket, guest + logged-in purchase (`@places-real-order`), Shop PLP (`/category/shop`), PDP content, PDP finish/extras, configurator (incl. Installation), product registration (`@completes-registration`), warranty finder, search drawer, sitemap redirects, footer newsletter.
- Last recorded staging regressions: 36/38 (2026-10-12), 37/39 (2026-10-13); both failures were WAF blocks or the since-removed Installation box.
- Gap/risk: `footer-newsletter-signup.feature` submits a real subscription with a unique guest email but is NOT tagged `@submits-real-form`, so it runs on prod. Worth confirming whether that is acceptable.
- Logged-in purchase navigates via the Shop category for real but buys the sink flange, because the first Shop item (`standard-460`) is a configurable bundle.

## Tips for extending
- Port from or to the EU suite first; most files are near-identical. Remember the UK site has no country modal and no locale prefix.
- Use `mastercard`, not `default`, for any new UK payment step.
- Tag anything that writes real data (`@places-real-order`, `@completes-registration`, `@submits-real-form`) so prod excludes it.
- Before debugging a timeout, check the screenshot for the WAF block page; don't chase it in test code.
- Narrow `FEATURE_PATH` while iterating; staging WAF gets worse under heavy run volume.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
