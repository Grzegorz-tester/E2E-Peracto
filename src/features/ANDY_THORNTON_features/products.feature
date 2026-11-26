@regression
Feature: Products page functionality

  # 2026-11-22: "Filtering products narrows the result count" removed - "Clearing a filter" below makes the same steps first.
  # 2026-11-22: "Sorting products changes the result order" removed - category-plp.feature's price sort scenarios apply the same sort and check the real order.

  # Smoke case 22 (AN-2026-11-19.json): clearing the filter brings the full
  # result set back. There is no "clear all" button on AT's filter drawer
  # (checked live 2026-11-19), so the facet is unticked instead.
  Scenario: Clearing a filter restores the full result count
    Given I am on the "dining-chairs" page
    When I remember the text of "hit count" as "count before filtering"
    And I click on the "Filter" button
    And I check the "facet checkbox", retrying until it is checked
    Then the "hit count" text should not equal the remembered "count before filtering"
    When I uncheck the "facet checkbox"
    Then the "hit count" text should equal the remembered "count before filtering"
