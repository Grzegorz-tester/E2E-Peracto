@regression
Feature: Product listing - browse, filter and sort

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. Filtering, sorting and pagination each trigger a real page
  # navigation (not an in-place AJAX re-render), and the PLP's page size is
  # large enough that raw product-card COUNT doesn't reliably change
  # between an unfiltered vs filtered/sorted/paginated view - the listed
  # products themselves do, so every assertion below compares the first
  # product card's title before and after, rather than counting cards.
  #
  # "first product card title"/"first product card link"/"product card"
  # are scoped to "#results-container" (not a bare ".card-fresh"),
  # confirmed necessary live on PRODUCTION 2026-09-09: watco.co.uk/floors
  # renders a static "Bestsellers" merchandising block ABOVE the real,
  # query-driven grid, using the exact same ".card-fresh" card component -
  # a bare ":nth-match(.card-fresh__title, 1)" silently reads the
  # Bestsellers section's own (never-changing) first card instead of the
  # real grid's. This produced a FALSE-POSITIVE "sort/filter/pagination
  # broken on production" finding (initially treated as a confirmed site
  # bug, including via independent network-level investigation that made
  # the same scoping mistake) - re-verified with the corrected
  # "#results-container" scope that filter, sort and pagination all
  # genuinely update the real grid's first result correctly on production;
  # staging-uk has no separate Bestsellers block so this scope change is a
  # no-op there (same 24 cards either way).
  #
  # Sort is selected by ORDINAL POSITION ("3rd" = Price Low to High on
  # staging-uk's own sort dropdown order: Most Popular, High-Low, Low-High,
  # A-Z, Z-A), not by its literal (locale-specific) label text, so this
  # scenario doesn't need translating per market - only re-verifying that
  # each market's own dropdown keeps products/pricing in the same relative
  # position. Same reasoning for using the 2nd brand filter checkbox
  # (position, not a specific brand name) rather than the very first, which
  # on staging-uk covers virtually every product and barely narrows
  # anything.
  #
  # CONFIRMED SITE BUG (staging-uk, same class as search results - see
  # link-navigation.ts's "... via its href on this origin" step): every
  # "View product" card link is an absolute URL pointing at an internal
  # Bloomreach content host that doesn't resolve publicly.

  Background:
    Given I am on the "plp" page
    And I click on the "Accept cookies" button if present

  Scenario: Browsing a category lists products that each link to their own PDP
    Then the "product card" should be displayed
    When I remember the text of "first product card title" as "listed product title"
    And I click on the "first product card link" link via its href on this origin
    Then I should be redirected to the "pdp" page
    And the "PDP title" text should equal the remembered "listed product title"

  Scenario: Filtering by brand changes the listed products
    When I remember the text of "first product card title" as "title before filter"
    And I click on the "second brand filter checkbox" element
    Then the current URL should contain "filters="
    And the "first product card title" text should not equal the remembered "title before filter"

  Scenario: Sorting changes the listed products
    When I remember the text of "first product card title" as "title before sort"
    And I select the "3rd" option from the "sort dropdown" dropdown
    Then the current URL should contain "sort="
    And the "first product card title" text should not equal the remembered "title before sort"

  # Added after a live bug ticket (2026-09-09) reported watco.co.uk/floors
  # production price sorting was scrambled in both directions - the previous
  # "Sorting changes the listed products" scenario above only asserted the
  # first card's TITLE changed after picking a sort option, which stays true
  # even if the resulting order isn't actually sorted by price at all, so it
  # never caught this. "product card price" is scoped the same way as
  # "product card"/"first product card title" (see the Bestsellers-block
  # comment above) to avoid the same false-positive/negative class of bug.
  #
  # CONFIRMED SITE BUG (both staging-uk AND production, re-verified live
  # 2026-09-09 - this is not a test-scoping artefact, unlike the Bestsellers
  # false-positive above): neither price-sort direction produces a correctly
  # ordered grid on either environment. E.g. staging-uk High-Low page 1:
  # ...,"£82.20","£284.50",... and Low-High page 1: ...,"£9.50","£4.90",...
  # - scattered reversals throughout, not just a single off-by-one. These
  # two scenarios are EXPECTED TO STAY RED until the real sort defect is
  # fixed site-side; don't dismiss a failure here as test flakiness.
  Scenario: Sorting by price - high to low orders products correctly
    When I select the "2nd" option from the "sort dropdown" dropdown
    Then the current URL should contain "sort="
    And the "product card price" prices should be sorted in "descending" order

  Scenario: Sorting by price - low to high orders products correctly
    When I select the "3rd" option from the "sort dropdown" dropdown
    Then the current URL should contain "sort="
    And the "product card price" prices should be sorted in "ascending" order

  Scenario: Paginating to the next page changes the listed products
    When I remember the text of "first product card title" as "title on page 1"
    And I click on the "page 2 link" link
    Then the current URL should contain "page=2"
    And the "first product card title" text should not equal the remembered "title on page 1"
