@regression
Feature: Health check

  # Ported from the Insinkerator_EU suite's equivalent health-check.feature.
  # This storefront is UK-only (single market), so unlike Insinkerator_EU
  # there is no mandatory "Choose your country" modal to dismiss on load.

  @smoke
  Scenario: User can load the home page
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    Then the "brand bar" should be displayed
