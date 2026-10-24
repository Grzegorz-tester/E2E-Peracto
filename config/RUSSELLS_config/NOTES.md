# RUSSELLS automation notes

Russells agricultural and machinery parts storefront (Peracto, Algolia search). Runs `src/features/RUSSELLS_features/` (22 features, about 50 scenarios). Migrated on 2026-08-31 from the separate P3Playwright repo (`playwright/projects/russells`); the folder was `src/features/Russells` before the 2026-10-19 rename.

## Environments
- `env/RUSSELLS_STAGING.env` -> `staging.russells-parts.work`. Staging: real orders fine. `LOGIN_SUCCESS_URL` is `/account` (not `/` like most projects).
- `hosts.json` has an empty `release_branch` and `dev` (`localhost:3001`). No release or production env exists.
- `PARALLEL=1`, which the wishlist scenarios rely on (shared, persistent wishlist state).
- Admin site: see `config/RUSSELLS_ADMIN_config/NOTES.md`.

## Test accounts and data
- `users.json`: `logged in`, `guest`, `wishlist admin`.
- `.env` names: `RUSSELLS_LOGGED_IN_EMAIL/_PASSWORD` (regular account, no wishlist access) and `RUSSELLS_WISHLIST_ADMIN_EMAIL/_PASSWORD` (account with wishlist access). These must stay two distinct accounts: the non-admin 404 scenario depends on it. Not to be confused with `RUSSELLS_ADMIN_ADMIN_*`, which logs into the Peracto Admin site. Both storefront logins were re-checked 2026-10-22 after the `.env` restore.
- The `logged in` account has a permanent fixture delivery + billing address (checkout selects it). Address-book scenarios add one more, edit and remove it; never delete the fixture.
- The `logged in` account permanently has at least one real order from logged-in-purchase-journey.feature; account-orders.feature depends on it.
- Wishlists created by the suite are named "Playwright QA ..."; the cleanup step refuses to delete anything without that prefix.
- Basket scenarios use `/products/walterscheid-universal-joint-32-x-76mm-standard-duty`.
- change-password.feature changes the shared account's real password to a documented temporary value and back. If it fails between the two steps, every logged-in scenario breaks until someone signs in with the temporary password (in the feature file) and resets it via Account > Profile.

## Known site defects (expected red)
- Sitemap `article_categories` category: a ~78,600-item list whose items never become visible (RUS-474). Skipped, not asserted.
- No other confirmed defects recorded. The suite has not had a recorded full live run.

## Quirks and gotchas
- **Unverified migration**: selectors were ported as-is; dry-run confirmed every step and element key resolves, but nothing was run against live staging at migration time (2026-08-31). Treat first failures as likely selector drift before suspecting the site.
- PDP collection-depot picker selectors are last-resort text/role/id (no data-testids, RUS-474): highest drift risk.
- Depot Finder search assumes Enter submits (not click-verified).
- Product name/SKU/price and Add to Basket need `:visible` / `>> nth=0` scoping (fixed during migration). Real checkout routes are `/checkout/review-and-payment` and `/checkout/thank-you`.
- Filter drawer has no close button; the drawer-close steps fall back to Escape.
- VAT toggle's visible label always reads "Incl. VAT"; the checkbox state (read via the PDP tax message) is the real signal.
- Algolia sort legitimately resets "Load more" pagination to page one (shared widget with Insinkerator); not a bug.
- PayPal integration points at PayPal's production environment even on staging: the PayPal scenario only checks the popup redirect, never authenticates.
- Header search is an always-visible Algolia autocomplete (not a drawer like Insinkerator).

## Coverage and gaps
- Covered: login, change password, address book, orders, wishlists (admin and non-admin), basket (qty, invalid/valid promo), category PLP (filter/sort/load more), parts finder, depot finder, PDP content and collection depot, search, VAT toggle, footer newsletter, quick enquiry form, sitemap, health check, guest/logged-in/click-and-collect purchase journeys, PayPal and declined card, guest checkout address editing.
- Real orders: guest, logged-in and click-and-collect purchase journeys each place one per run (tagged `@places-real-order`, staging-guarded). Keep to one run per suite execution.
- Real form submissions: footer newsletter success scenario and quick enquiry "valid submission reaches the backend" (expects 201). Check whether these notify Russells staff before running often.
- Dropped from the source suite: depot finder map recentre and pin count, parts finder "brand list differs by machine type", exact 1.2x VAT ratio (asserts "price changed" only), basket discount-amount tolerance.
- No PDP FAQ, carousel comparison, zoom or configurator found on Russells (RUS-474).

## Tips for extending
- Run narrow `FEATURE_PATH`s first; this suite still needs a full live baseline.
- Any new wishlist scenario must use the "Playwright QA" prefix and must not run in parallel with the others.
- Mark checkout data as "Velstar Test".

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
