# WATCO_NL automation notes

Watco Netherlands storefront. Runs `src/features/WATCO_NL_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_NL_STAGING.env` -> https://staging-nl.watco.pub (staging, free rein; slug `watco_nl`).
- `env/WATCO_NL_PROD.env` -> https://www.watco.nl (production, read-only: no orders, registration or real forms; slug `watco_nl_prod`).

## Test accounts and data
- `WATCO_NL_ACCOUNT_TEST_USER_1_*`, `WATCO_NL_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_NL_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_NL_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod).
- `WATCO_NL_PROD_ACCOUNT_TEST_USER_1` password INVALID at the 2026-10-22 check; needs a new one from the user.
- Staging "account test user 1" is not email-verified (as of 2026-09-07), so order history is gated.

## Known site defects (expected red)
- order-history.feature fails until the staging test account's email is verified (account data).
- Shared PLP price-sort defect.

## Quirks and gotchas
- Pay on Account is HIDDEN until a valid VAT number is applied (like DE/BE-NL); a saved-VAT logged-in account sees it on load.
- Zero-rating is simpler than DE: ANY valid NL VAT zero-rates (21% to 0%), even domestic NL-to-NL delivery, so the persistence scenario expects a zero VAT amount.
- Business-customer comment under the VAT field. Profile "Save details" button is "Opslaan".
- Pay on Account is "Betaling op facturatie".
- Routes: `/winkelmandje`, `/de-bestelling-valideren`, `/inloggen`, `/vloeren`; "Update basket" posts to untranslated `/basket/update`. `added-to-basket` route in pages.json is `/added-to-basket` (not re-checked since 2026-09-07).

## Coverage and gaps
- Staging 13/14 on 2026-09-07 (only order history red).
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no NL mappings yet; expect failures.

## Tips for extending
- VAT persistence baseline is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
