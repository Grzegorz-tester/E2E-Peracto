# WATCO_IE automation notes

Watco Ireland storefront, English-language and structurally identical to UK (zero config divergence found during the 2026-09-06/07 rollout). Runs `src/features/WATCO_IE_features/` (VAT suite) plus the shared `src/features/WATCO_SHARED_features/`.

Shared Watco quirks: see config/WATCO_config/NOTES.md

## Environments
- `env/WATCO_IE_STAGING.env` -> https://staging-ie.watco.pub (staging, free rein; slug `watco_ie`).
- `env/WATCO_IE_PROD.env` -> https://www.watco.ie (production, read-only: no orders, registration or real forms; slug `watco_ie_prod`).

## Test accounts and data
- `WATCO_IE_ACCOUNT_TEST_USER_1_*`, `WATCO_IE_ACCOUNT_TEST_USER_WITH_VAT_*` (staging); `WATCO_IE_PROD_ACCOUNT_TEST_USER_1_*`, `WATCO_IE_PROD_ACCOUNT_TEST_USER_WITH_VAT_*` (prod). Working at the 2026-10-22 check.
- Staging "account test user 1" IS verified and has a real order, so order history works (the only non-UK market where it does, as of 2026-09-07).
- Registration requires email verification (like UK). Registration scenarios create real throwaway accounts on staging each run.

## Known site defects (expected red)
- Shared PLP price-sort defect.

## Quirks and gotchas
- VAT format IE9999999L, 23% rate, EUR. A longer value (7 digits + 2 letters) is also accepted. No XI-style prefix (UK only).
- Pay on Account always offered regardless of VAT, with a EUR 500 minimum and the new-customer minimum-order notice (UK and IE only).
- Routes are the same English paths as UK (`/basket`, `/checkout`, `/floors`, `/login`).

## Coverage and gaps
- Staging 14/14 on 2026-09-07.
- Shared scenarios added 2026-09-09 (vat-toggle, search, quote, pdp swatch/reviews) have no IE mappings yet; expect failures. Given IE mirrors UK, copying UK's keys is the likely fix (unverified).
- UK's `pdp-datasheet-and-cross-sell.feature` is not ported (needs an equivalent IE SKU confirmed).

## Tips for extending
- VAT persistence baseline is in `logged-in-checkout-vat-persistence.feature`'s docblock.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
