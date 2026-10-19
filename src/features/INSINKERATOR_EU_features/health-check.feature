@regression
Feature: Health check

  # Ported from P3Playwright's insinkerator_eu/tests/health-check.test.ts.

  @smoke
  Scenario: User can load the home page
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    Then the "brand bar" should be displayed
