# WATCO_DE automation notes

Watco Germany storefront. Runs `src/features/WATCO_DE_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_DE_STAGING.env` -> https://staging-de.watco.pub (staging, free rein; slug `watco_de`).
- `env/WATCO_DE_PROD.env` -> https://www.watco.de (production, read-only: no orders, registration or real forms; slug `watco_de_prod`).

## Test accounts and data
- `WATCO_DE_ACCOUNT_TEST_USER_1_*`, `WATCO_DE_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_DE_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_DE_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod). Working at the 2026-10-22 check.
- Staging "account test user 1" is not email-verified (as of 2026-09-07), so order history is gated.
- Registration scenarios create real throwaway accounts on staging each run (2026-10-20 audit).

## Known site defects (expected red)
- order-history.feature fails until the staging test account's email is verified (account data).
- Shared PLP price-sort defect.

## Quirks and gotchas
- Pay on Account ("Zahlung auf Rechnung") is HIDDEN until a valid VAT number is applied; a saved-VAT logged-in account sees it on load. Without valid VAT, validation scenarios use "Pay by card"/Adyen terms.
- Zero-rating is delivery-country aware: domestic DE-to-DE delivery keeps VAT, so the persistence scenario (Berlin address) expects VAT to carry through unchanged. Cross-border delivery is out of scope.
- Business-customer comment under the VAT field. No new-customer minimum-order notice (UK/IE only).
- Routes: `/warenkorb`, `/kasse`, `/anmelden`, `/boden`, profile `/kundenkonto/profil`; order list route contains a non-ASCII character (`/kundenkonto/bestellung/übersicht`). "Update basket" posts to `/basket/update`; `added-to-basket` is `/zum-warenkorb-hinzugefuegt` (fixed 2026-09-07).
- German option labels (Title, Job function, Industry sector) are selected by ordinal, skipping the blank placeholder.

## Coverage and gaps
- Staging 13/14 on 2026-09-07 (only order history red).
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no DE mappings yet; expect failures.

## Tips for extending
- VAT persistence baseline is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
