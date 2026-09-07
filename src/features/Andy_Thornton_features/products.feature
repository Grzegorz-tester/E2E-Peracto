@Andy_Thornton_regression
Feature: Products page functionality

  Scenario: Filtering products narrows the result count
    Given I am on the "dining-chairs" page
    When I remember the text of "hit count" as "count before filtering"
    And I click on the "Filter" button
    And I check the "facet checkbox", retrying until it is checked
    Then the "hit count" text should not equal the remembered "count before filtering"

  Scenario: Sorting products changes the result order
    Given I am on the "dining-chairs" page
    When I remember the text of "first product name" as "first product before sorting"
    And I select the "Sort By: Price - low to high" option from the "Sort By" listbox
    Then the "first product name" text should not equal the remembered "first product before sorting"
