@regression
Feature: Filtering Orders By Order Reference Or Email

  # Shared Peracto Admin boilerplate (per CLAUDE.md: every Peracto Admin
  # tenant runs the same underlying product) - same shape as this folder's
  # product-filtering.feature. CONFIRMED LIVE identical across every
  # tenant checked (MIPA, KOOL, Carbon, Indespension): the Orders list's
  # filter panel testids (`text-filter-order-reference`, `text-filter-
  # email`, `apply-filter-button`, `reset-filter-button`) and row testids
  # (`row-N-order-reference`, `row-N-email`) are the same everywhere, and
  # the filter inputs are visible without opening a "Filters" toggle
  # first. "Order Reference" and "Email" mapping keys already existed in
  # every tenant's own orders.json before this feature (pre-scaffolded),
  # confirming this is expected, standard Peracto Admin behaviour, not
  # something new being bolted on. Read-only, so - unlike this folder's
  # scenarios that create/trigger real data - safe against a tenant with
  # a production admin too.
  #
  # Uses whichever order is genuinely first in the list right now rather
  # than a hardcoded reference/email, for the same reason product-
  # filtering.feature does - real order data differs per tenant and
  # changes over time. Resets the filter first for the same reason that
  # feature does too: Peracto Admin persists a list's last-applied filter
  # server-side per logged-in user, so a fresh browser session can still
  # inherit an earlier scenario's (or an earlier regression run's)
  # filter otherwise.
  #
  # CONFIRMED (live, 2026-08-31): every order in MIPA's own staging data
  # currently shares the same test email, so filtering by email there
  # never visibly narrows the row count - a data characteristic, not a
  # broken filter (the same "Mipa" vs `product name` situation
  # product-filtering.feature already accounts for). This only asserts
  # the matching row is still present and correct after filtering, not
  # that the row count drops, so it stays valid regardless of how much a
  # given tenant's real order data happens to overlap on email.

  Background:
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Orders" element
    And I click precisely on the "Reset" element

  Scenario Outline: Filtering orders by <field> returns a matching order

    When I remember the text of the first non-empty "<row values>" as "filter term"
    And I fill in the "<filter field>" input field with the remembered "filter term"
    And I click precisely on the "Apply" element
    Then the "<row values>" should contain the remembered "filter term"

    Examples:
      | field           | row values             | filter field     |
      | Order Reference | order reference cells  | Order Reference  |
      | Email           | order email cells      | Email            |

  Scenario: Filtering orders by a reference that matches nothing shows the empty state
    When I fill in the "Order Reference" input field with "zzz-no-such-order-regression-test-zzz"
    And I click precisely on the "Apply" element
    Then the "no results message" should be displayed
    And the "table row" should not be displayed
