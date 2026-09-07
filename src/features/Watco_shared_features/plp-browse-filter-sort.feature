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

  Scenario: Paginating to the next page changes the listed products
    When I remember the text of "first product card title" as "title on page 1"
    And I click on the "page 2 link" link
    Then the current URL should contain "page=2"
    And the "first product card title" text should not equal the remembered "title on page 1"
