@regression
@carbon_regression
Feature: Attributes Page

  Scenario: Redirection to Attributes
    Given I am navigating the page as a "logged in" user
    When I click on the "Products" tab
    And I click on the "Attributes" tab
    And I click on the "All Attributes" tab
    Then I should be redirected to the "attributes" page

  Scenario: Filter attributes by Label

  Scenario: Filter attributes by Code

  Scenario: Navigate to a specific attribute

  Scenario: Delete an attribute