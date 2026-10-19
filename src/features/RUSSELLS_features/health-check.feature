@regression @smoke
Feature: Health check

  Scenario: The home page loads for a guest user
    Given I am navigating the page as a "guest" user
    And I click on the "Accept cookies" button if present
    Then the "header logo" should be displayed
