@regression
@carbon_regression
Feature: Products Page

  Scenario: Redirection to Products
    Given I am navigating the page as a "logged in" user
    When I click on the "Products" tab
    And I click on the "All Products" tab
    Then I should be redirected to the "products" page

  Scenario: Filter products by Name

  Scenario: Filter products by SKU

  Scenario: Filter products by Status

  Scenario: Navigate to a specific product

  Scenario: Verify pagination on Products page

  Scenario: Export Product Data

  Scenario: Delete a product