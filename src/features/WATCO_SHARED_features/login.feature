@regression
Feature: Login

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk with the shared "account test user 1" credentials.

  Scenario: Logging in with valid credentials reaches the account area
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page

  Scenario: Logging in with an incorrect password shows an error and does not log in
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with "DefinitelyWrongPassword123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "login error message" should be displayed
    And I should be redirected to the "login" page
