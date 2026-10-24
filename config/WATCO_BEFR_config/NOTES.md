# WATCO_BEFR automation notes

Watco Belgium, French-language storefront. Runs `src/features/WATCO_BEFR_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_BEFR_STAGING.env` -> https://staging-befr.watco.pub (staging, free rein; slug `watco_befr`).
- `env/WATCO_BEFR_PROD.env` -> https://fr.watcodirect.be (production, read-only: no orders, registration or real forms; slug `watco_befr_prod`).

## Test accounts and data
- `WATCO_BEFR_ACCOUNT_TEST_USER_1_*`, `WATCO_BEFR_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_BEFR_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_BEFR_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod).
- `WATCO_BEFR_PROD_ACCOUNT_TEST_USER_1` password INVALID at the 2026-10-22 check ("Identifiants invalides"); needs a new one from the user.
- Staging "account test user 1" is not email-verified (as of 2026-09-07), so order history shows a verify-your-email gate.
- Registration activates accounts immediately (like FR).

## Known site defects (expected red)
- PLP card titles carry a marketing suffix (e.g. "Mortier Coulable - Mortier de réparation multi-usage") that the PDP `<h1>` doesn't show, breaking the "listed product links to its own PDP" title match. Real content defect, left red (2026-09-07).
- order-history.feature fails until the staging test account's email is verified (account data, not a test bug).
- Shared PLP price-sort defect.

## Quirks and gotchas
- Shares FR's URL paths (`/panier`, `/valider-la-commande`, `/se-connecter`, `/sols`).
- RETRACTED: an earlier note said BE-FR VAT-gates Pay on Account like DE/NL/BE-NL. Live testing (8/8) showed it is ALWAYS offered, like FR/UK/IE.
- A valid VAT number drops the VAT summary row from 21% to 0%; it sometimes recalculates slowly enough to need a retry.
- QA doc claimed a NIP/NIP-EU field pair here: false (copy-paste from PL). One VAT input, same id platform-wide.
- VAT label is "Numéro de TVA client" (FR's is "Numéro de TVA"); not asserted by text.
- Pay on Account is "Paiement sur facturation" (checked absent from Express).

## Coverage and gaps
- Staging shared + VAT suite 12/14 on 2026-09-07 (order history + PLP title mismatch).
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no BEFR mappings yet; expect failures.
- `"product card price"` uses bare `.card-fresh` (not `#results-container`); check for a Bestsellers block before trusting prod PLP assertions.

## Tips for extending
- VAT persistence baseline for "account test user with vat" is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
