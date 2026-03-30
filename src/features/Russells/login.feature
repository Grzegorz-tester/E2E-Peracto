@Russells_regression
Feature: Login functionality

  @smoke
  Scenario: Successful login with valid credentials
    Given I am on the "login" page
    When I fill in the "Email address" input field with "grzegorz.hajduk@velstar.co.uk"
    And I fill in the "Password" input field with "Testing123"
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

  Scenario: Login fails with wrong password
    Given I am on the "login" page
    When I fill in the "Email address" input field with "grzegorz.hajduk@velstar.co.uk"
    And I fill in the "Password" input field with "wrongpassword"
    And I click on the "Sign In" button
    Then I should be redirected to the "login" page

  Scenario: Login fails with empty fields
    Given I am on the "login" page
    When I click on the "Sign In" button
    Then I should be redirected to the "login" page

  Scenario: Forgotten password link redirects to reset password page
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
