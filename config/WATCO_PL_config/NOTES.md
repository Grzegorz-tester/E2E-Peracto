# WATCO_PL automation notes

Watco Poland storefront. Runs `src/features/WATCO_PL_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_PL_STAGING.env` -> https://staging-pl.watco.pub (staging, free rein; slug `watco_pl`).
- `env/WATCO_PL_PROD.env` -> https://www.watco.pl (production, read-only: no orders, registration or real forms; slug `watco_pl_prod`).

## Test accounts and data
- `WATCO_PL_ACCOUNT_TEST_USER_1_*`, `WATCO_PL_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_PL_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_PL_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod). Working at the 2026-10-22 check.
- Staging "account test user 1" is not email-verified (as of 2026-09-07), so order history is gated.
- "account test user with vat" has a saved NIP-EU but no saved NIP.

## Known site defects (expected red)
- order-history.feature fails until the staging test account's email is verified (account data).
- Shared PLP price-sort defect.

## Quirks and gotchas
- The only market with TWO tax fields: NIP (domestic, no tax effect, no comment) and NIP-EU (reuses the platform-wide "VAT number" input id, has a comment, and is the only one that zero-rates). Any valid NIP-EU zero-rates (23% to 0%), domestic included.
- Pay on Account is entirely ABSENT from the DOM at every stage (not CSS-hidden as on DE/NL/BE-NL). Validation blocking is shown via card/Adyen instead.
- Persistence scenario pays with a real Adyen test card (staging Adyen is in test mode, no 3DS challenge, per the source repo 2026-08-06). The feature's docblock says the new Adyen step had not yet been run live in this framework; confirm before trusting a pass or fail (status after that unknown).
- NIP and NIP-EU validation errors use different copy (NIP-EU's example carries a "PL" prefix, NIP's doesn't); both asserted as current behaviour.
- Select placeholders read "Wybierz opcję": pick "2nd" (first real option), "1st" silently leaves the placeholder and the required-field block fires.
- Profile save redirects back to itself; wait before reloading or the reload races the redirect.
- Cookie preference-centre overlay re-renders between dismiss and click here: use the `dismissing ... if it interferes` click variant.
- Routes: `/koszyk`, `/realizacja-transakcji`, `/logowanie`, `/posadzki`, profile `/konto/profil-klienta`. "Update basket" posts to `/basket/update`; `added-to-basket` is `/dodano-do-koszyka` (fixed 2026-09-07).

## Coverage and gaps
- Staging 13/14 on 2026-09-07 (only order history red).
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no PL mappings yet; expect failures.

## Tips for extending
- VAT persistence baseline is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
