@Andy_Thornton_regression
Feature: Verify PLP elements

  Scenario: Verify category listing page elements
    Given I am on the "dining-chairs" page
    Then the "page title" should contain the text "Dining Chairs"
    And the "breadcrumb" should be displayed
    And the "hit count" should be displayed
    And the "Filter" should be displayed
    And the "Sort By" should be displayed
    And the "product card" should be displayed
