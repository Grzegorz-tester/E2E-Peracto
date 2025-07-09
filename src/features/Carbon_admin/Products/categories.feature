@regression
@carbon_regression
Feature: Categories Page

  Scenario: Redirection to Categories
    Given I am navigating the page as a "logged in" user
    When I click on the "Products" tab
    And I click on the "Categories" tab
    Then I should be redirected to the "categories" page

  Scenario: Filter category by Name

  Scenario: Filter category by Status

  Scenario: Navigate to a specific category

  Scenario: Export Category Data

  Scenario: Delete a category