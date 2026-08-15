@regression
Feature: Login and password reset

  # Ported from Insinkerator_EU's logging-in.feature. This storefront is
  # UK-only - no country-selection modal to dismiss, unlike the EU site.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: Submitting an empty login form is rejected by client-side validation
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I click on the "Sign In" button
    Then the "login alert" should not be displayed

  Scenario: User cannot log in with a wrong password
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "WrongPassword123!"
    And I click on the "Sign In" button
    Then the "login alert" should contain the text "Invalid credentials."
    And I should be redirected to the "login" page

  Scenario: User can request a password reset via the Forgotten password link
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I click on the "Forgotten your password" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I click on the "Submit" button
    Then the "reset password success message" should be displayed
