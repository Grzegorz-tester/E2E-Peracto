# WATCO_BENL automation notes

Watco Belgium, Dutch-language storefront. Runs `src/features/WATCO_BENL_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_BENL_STAGING.env` -> https://staging-benl.watco.pub (staging, free rein; slug `watco_benl`).
- `env/WATCO_BENL_PROD.env` -> https://www.watcodirect.be (production, read-only: no orders, registration or real forms; slug `watco_benl_prod`).

## Test accounts and data
- `WATCO_BENL_ACCOUNT_TEST_USER_1_*`, `WATCO_BENL_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_BENL_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_BENL_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod).
- `WATCO_BENL_PROD_ACCOUNT_TEST_USER_1` password INVALID at the 2026-10-22 check; needs a new one from the user.
- Staging "account test user 1" is not email-verified (as of 2026-09-07), so order history is gated.

## Known site defects (expected red)
- order-history.feature fails until the staging test account's email is verified (account data).
- Shared PLP price-sort defect.

## Quirks and gotchas
- Adyen drop-in opens on "Bancontact card" (also offers card, Apple Pay, Google Pay). "Adyen pay button" is scoped to the selected method; see the Adyen quirk in `WATCO_config/NOTES.md`. Confirmed 2026-10-24.
- Behaves like NL: Pay on Account is HIDDEN until a valid VAT number is applied (CSS gating). A logged-in account with a saved VAT sees it on load (field arrives already applied). Without valid VAT, the validation scenario blocks via "Pay by card"/Adyen terms instead.
- Business-customer comment under the VAT field (same text as NL). Label "Btw-nummer" (NL: "Belasting over de toegevoegde waarde"); not asserted by text.
- Valid VAT zero-rates (21% to 0%), domestic included.
- Pay on Account is "Betaling op facturatie".
- Routes: `/winkelmandje`, `/de-bestelling-valideren`, `/inloggen`, `/vloeren`; "Update basket" still posts to untranslated `/basket/update`. `added-to-basket` route in pages.json is `/added-to-basket` (not re-checked since 2026-09-07).

## Coverage and gaps
- Staging 13/14 on 2026-09-07 (only order history red).
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no BENL mappings yet; expect failures.

## Tips for extending
- VAT persistence baseline is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
