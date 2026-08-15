@regression
Feature: Login and password reset

  # Ported from P3Playwright's insinkerator_eu/tests/account/login.test.ts.
  # Every fresh page load on this storefront shows a mandatory "Choose your
  # country" modal (Portugal is used here as an ecommerce-enabled country)
  # that must be dismissed before anything else is interactable.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present

  @smoke
  Scenario: Submitting an empty login form is rejected by client-side validation
    Given I am on the "login" page
    When I click on the "Sign In" button
    Then the "login alert" should not be displayed

  Scenario: User cannot log in with a wrong password
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "WrongPassword123!"
    And I click on the "Sign In" button
    Then the "login alert" should contain the text "Invalid credentials."
    And I should be redirected to the "login" page

  Scenario: User can request a password reset via the Forgotten password link
    Given I am on the "login" page
    When I click on the "Forgotten your password" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I click on the "Submit" button
    Then the "reset password success message" should be displayed
