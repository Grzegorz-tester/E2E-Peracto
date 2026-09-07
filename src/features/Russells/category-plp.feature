@regression
Feature: Category PLP

  # Covers a real, filterable Algolia-backed category PLP, reached via the
  # header nav's "General Parts" hub page -> a sub-category tile.

  @smoke
  Scenario: User can filter, sort, load more, and reach the correct PDP
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I choose the "General Parts" category from the menu
    And I click on the sub-category tile for "general-parts-pto-driveline-components"
    Then I should be redirected to the "category" page
    And the "hits heading" should be displayed
    And the "product card" should be displayed

    When I click on the "filter and sort open button" button
    And I apply the first facet filter and validate the result count updates
    And I sort by price low to high and validate ascending order
    And I load more results and validate the count increases

    When I remember the text of "first product card name" as "product name"
    And I click on the "1st" "product card" element
    Then I should be redirected to the "products" page
    And the "product name" text should equal the remembered "product name"
