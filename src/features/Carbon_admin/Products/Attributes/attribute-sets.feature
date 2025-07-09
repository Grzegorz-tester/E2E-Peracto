@regression
@carbon_regression
Feature: Attribute Sets Page

  Scenario: Redirection to Attribute Sets
    Given I am navigating the page as a "logged in" user
    When I click on the "Products" tab
    And I click on the "Attributes" tab
    And I click on the "Attribute Sets" tab
    Then I should be redirected to the "attribute-sets" page

  Scenario: Filter attribute-sets by Name

  Scenario: Navigate to a specific attribute-sets

  Scenario: Delete an attribute-sets