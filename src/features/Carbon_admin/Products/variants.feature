@regression
@carbon_regression
Feature: Variants Page

  Scenario: Redirection to Variants
    Given I am navigating the page as a "logged in" user
    When I click on the "Products" tab
    And I click on the "Product Variants" tab
    Then I should be redirected to the "variants" page

  Scenario: Filter variants by Name

  Scenario: Filter variants by SKU

  Scenario: Filter variants by Status

  Scenario: Filter variants by Availability

  Scenario: Navigate to a specific variants

  Scenario: Verify pagination on Variants page

  Scenario: Delete a variant