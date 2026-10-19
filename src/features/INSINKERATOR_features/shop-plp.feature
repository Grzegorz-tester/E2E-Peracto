@regression
Feature: Shop PLP

  # Reworked from this project's own accessories-plp.feature: the header
  # nav's "Shop" link (-> /category/shop) is now the PLP under test instead
  # of /category/accessories - same underlying Algolia-driven PLP template
  # (hits heading/count, facet filters, sort, infinite-scroll load more,
  # product cards), confirmed live to expose the same data-testids and
  # filter/sort/load-more behaviour as the accessories category did.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: User can filter, sort, load more, and reach the correct PDP
    When I navigate directly to the path "/category/shop"
    Then the "hits heading" should be displayed
    And the "hit count" should be displayed
    And the "product card" should be displayed

    When I click on the "Filter & Sort" button
    And I apply the first facet filter and validate the result count updates
    And I close the filter drawer
    And I load more results and validate the count increases

    When I click on the "Filter & Sort" button
    And I sort by price low to high and validate ascending order
    And I click the first PLP result and remember its name as "shop plp product"
    Then the "product name" text should equal the remembered "shop plp product"
