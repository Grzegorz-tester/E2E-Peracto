@smoke
@regression
Feature: Login Page

  # CONFIRMED live 2026-09-06: LOGIN_SUCCESS_URL is "/account", not "/" -
  # Keylite redirects a signed-in user straight to their account page rather
  # than back to the storefront home page like most other projects in this
  # repo.

  Scenario: Successful log in to the user's account
    Given I am on the "login" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
