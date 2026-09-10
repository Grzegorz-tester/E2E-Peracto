@regression
Feature: Home page

  Scenario: Verify page elements
    Given I am on the "home" page
    Then the "header logo" should be displayed
    And the "page title" should contain the text "Andy Thornton"
