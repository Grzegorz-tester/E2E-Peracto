@smoke
@regression
Feature: Product Listing Page (PLP) & Search

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > Product
  # Listing Page (PLP) & Search" (cases 532-536).

  Scenario: PLP loads with products displayed correctly
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    Then the "product card" should be displayed
    And the "product name" should be displayed
    And the "product price" should be displayed
    When I click on the "product name" element
    Then the current URL should contain "/products/"

  Scenario: PLP - Add product to basket from listing
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    Then the "no items message" should not be displayed

  # The exact refinement option names in "refinement filters" haven't been
  # confirmed live for this category - this exercises the 1st available
  # filter checkbox generically rather than a specific named one.
  Scenario: PLP - Apply filters and confirm results update
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    And I remember the number of "product card" elements as "unfiltered count"
    When I click on the "1st" "refinement filters" element
    Then the number of "product card" elements should be fewer than the remembered "unfiltered count"
    When I click on the "Clear all" button
    Then the number of "product card" elements should equal the remembered "unfiltered count"

  # No dedicated pagination/"load more" data-testid was found live on this
  # category - it may not paginate at this product count, or use a
  # mechanism not yet identified. Uses the generic "if present" click so
  # this reports cleanly rather than failing outright if there's nothing
  # to click; confirm the real mechanism before trusting this scenario.
  Scenario: PLP - Load more results or pagination works
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    And I remember the number of "product card" elements as "initial count"
    When I click on the "Load more results" button if present
    Then the number of "product card" elements should be more than the remembered "initial count"

  Scenario Outline: Search - Search by SKU and product name
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "<term>"
    And I wait for the search results to update
    Then the "first search result" should be displayed
    When I click on the "first search result" element
    Then the current URL should contain "/products/"

    Examples:
      | term      |
      | JAV-1071  |
      | JAVAC     |
