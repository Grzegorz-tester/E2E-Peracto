@regression
Feature: Search results

  # Shared across every Watco market. CONFIRMED LIVE (staging-uk,
  # 2026-09-09): every other scenario that types into "Search products"
  # (basket.feature, pdp.feature) only ever uses the search results page as
  # a stepping stone to reach a PDP - the results page itself, and its
  # zero-results state, were never directly asserted on. Confirmed that a
  # query with no genuine matches renders a "Products (0)" tab rather than
  # an empty/blank page or an error.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  # CONFIRMED LIVE (staging-uk, 2026-09-09): a zero-results search still
  # renders a "you might like" recommendations carousel using the SAME
  # ".card-fresh" component as genuine results, so "no result card
  # anywhere on the page" is not a valid zero-results signal - the "Viewing
  # 0 of 0" count and the "Products (0)" tab are the real, unambiguous
  # indicators.
  Scenario: A search with no matching products shows a zero-results state
    When I fill in the "Search products" input field with "zzzznoresultsxyz123"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    Then the "search products tab showing zero results" should be displayed
    And the "search viewing zero of zero count" should be displayed

  Scenario: A search with matching products lists them on the results page
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    Then the "search results heading" should be displayed
    And the "search result card" should be displayed
