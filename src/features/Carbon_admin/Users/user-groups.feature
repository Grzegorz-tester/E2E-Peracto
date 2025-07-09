@regression
@carbon_regression
Feature: User Groups Page

  Scenario: Redirection to User Groups
    Given I am navigating the page as a "logged in" user
    When I click on the "Users" tab
    And I click on the "User Groups" tab
    Then I should be redirected to the "user-groups" page


  Scenario: Navigate to a specific user-group
