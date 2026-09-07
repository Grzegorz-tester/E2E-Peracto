@regression
Feature: Filtering Products By Name Or SKU

  # Shared Peracto Admin boilerplate (per CLAUDE.md: KOOL, Indespension,
  # Carbon Admin and every other Peracto Admin tenant run the same
  # underlying product) - CONFIRMED LIVE identical across every tenant
  # checked (MIPA, KOOL, Carbon, Indespension): the Products list's
  # filter panel testids (`text-filter-name`, `text-filter-sku`,
  # `apply-filter-button`, `reset-filter-button`) and row testids
  # (`row-N-name`, `row-N-sku`) are the same everywhere, and the filter
  # inputs are visible without needing to open a "Filters" toggle first.
  # Read-only (a query, not a write), so - unlike this folder's other
  # scenarios that create/trigger real data - this is safe to run against
  # a tenant with a production admin too.
  #
  # Uses whichever product is genuinely first in the list right now
  # rather than a hardcoded name/SKU, since real catalogue data changes
  # per tenant and over time (same reason "first item link" is used
  # elsewhere in this shared suite instead of a specific product).
  #
  # CONFIRMED SITE QUIRK - Carbon Admin only (live, 2026-08-31): its
  # Products list has a genuinely blank-named seed row at position 0 (SKU
  # populated, name empty) - a real data quirk, not a selector miss. "the
  # first non-empty ..." remembers whichever row actually has a name
  # instead of assuming row 0 is it, so this scenario still works there
  # too rather than needing to exclude that tenant.

  Background:
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    # Confirmed live: Peracto Admin persists a list's applied filter
    # server-side per logged-in user, not just in this browser session -
    # without resetting first, a filter this suite applied in an EARLIER
    # scenario (or an earlier regression run) is still active here even
    # though this is a fresh browser context, silently narrowing "product
    # SKU"/"product name" candidates before this scenario gets to apply
    # its own filter.
    And I click precisely on the "Reset" element

  Scenario Outline: Filtering products by <field> narrows the list to a matching product

    When I remember the text of the first non-empty "<row values>" as "filter term"
    And I fill in the "<filter field>" input field with the remembered "filter term"
    And I click precisely on the "Apply" element
    Then the "<row values>" should contain the remembered "filter term"

    Examples:
      | field | row values  | filter field |
      | Name  | product name | Name filter |
      | SKU   | product SKU  | SKU filter   |

  Scenario: Filtering products by a name that matches nothing shows the empty state
    When I fill in the "Name filter" input field with "zzz-no-such-product-regression-test-zzz"
    And I click precisely on the "Apply" element
    Then the "no results message" should be displayed
    And the "table row" should not be displayed
