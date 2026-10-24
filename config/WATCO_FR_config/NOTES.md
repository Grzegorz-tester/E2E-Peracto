# WATCO_FR automation notes

Watco France storefront. Runs `src/features/WATCO_FR_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_FR_STAGING.env` -> https://staging-fr.watco.pub (staging, free rein; slug `watco_fr`).
- `env/WATCO_FR_PROD.env` -> https://www.watco.fr (production, read-only: no orders, registration or real forms; slug `watco_fr_prod`).

## Test accounts and data
- `WATCO_FR_ACCOUNT_TEST_USER_1_*`, `WATCO_FR_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_FR_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_FR_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod).
- `WATCO_FR_PROD_ACCOUNT_TEST_USER_1` password INVALID at the 2026-10-22 check; needs a new one from the user.
- Staging "account test user 1" is not email-verified (as of 2026-09-07), so order history is gated.
- Registration (`/senregistrer`) activates accounts immediately, no email verification (unlike UK/IE).

## Known site defects (expected red)
- order-history.feature fails until the staging test account's email is verified (account data).
- Shared PLP price-sort defect.

## Quirks and gotchas
- Pay on Account ("Paiement sur facturation") is always offered regardless of VAT, like UK; no new-customer minimum-order notice.
- URL paths are localised: `/panier`, `/valider-la-commande`, `/se-connecter`, `/sols`, profile `/mon-compte/informations-personnelles`. "Update basket" still posts to `/basket/update`; `added-to-basket` is `/ajoute-au-panier` (fixed 2026-09-07).
- Title dropdown has no English text: selected by ordinal ("2nd").

## Coverage and gaps
- Staging 13/14 on 2026-09-07 (only order history red).
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no FR mappings yet; expect failures.

## Tips for extending
- VAT persistence baseline is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
