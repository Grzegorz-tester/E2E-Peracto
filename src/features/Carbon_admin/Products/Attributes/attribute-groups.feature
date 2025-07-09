@regression
@carbon_regression
Feature: Attribute Groups Page

  Scenario: Redirection to Attribute Groups
    Given I am navigating the page as a "logged in" user
    When I click on the "Products" tab
    And I click on the "Attributes" tab
    And I click on the "Attribute Groups" tab
    Then I should be redirected to the "attribute-groups" page

  Scenario: Filter attribute-group by Name

  Scenario: Navigate to a specific attribute-group

  Scenario: Delete an attribute-group