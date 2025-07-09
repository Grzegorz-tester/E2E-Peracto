@regression
@carbon_regression
Feature: Users Page

  Scenario: Redirection to Users
    Given I am navigating the page as a "logged in" user
    When I click on the "Users" tab
    And I click on the "All Users" tab
    Then I should be redirected to the "users" page

  Scenario: Filter users by First Name

  Scenario: Filter users by Last Name

  Scenario: Filter users by Email

  Scenario: Navigate to a specific user

  Scenario: Verify pagination on users page

  Scenario: Export User Data

  Scenario: Delete a user