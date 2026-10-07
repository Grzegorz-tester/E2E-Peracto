@regression
Feature: Health check

  # Fast "is the storefront up" checks - run these first when triaging a red
  # JTDove run. Cookiebot is blocked by the runner (see BLOCK_REQUEST_HOSTS in
  # env/JTDove.env) so no consent banner is dismissed here.

  @smoke
  Scenario: User can load the home page
    Given I am on the "home" page
    And I wait for the page to settle
    Then the "header logo" should be displayed
    And the "header search input" should be displayed
    And the "navigation items" should be displayed


  @smoke
  Scenario: User can load a category listing
    Given I am on the "plywood" page
    And I wait for the page to settle
    Then the "PLP title" should contain the text "Plywood"
    And the "product card" should be displayed


  @smoke
  Scenario: User can load a product page
    Given I am on the "test-product" page
    And I wait for the page to settle
    Then the "product title" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "DELIVERY" should be displayed
