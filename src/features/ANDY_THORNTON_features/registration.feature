@regression
Feature: Registration

  # Built 2026-09-30 from a live inspection of staging. Register stays
  # disabled until the required fields are filled; password rules and
  # duplicate emails are only checked on submit, with the messages below
  # (all confirmed live).

  Background:
    Given I am on the "register" page
    And I click on the "Allow all cookies" button if present
    When I fill in the "First Name" input field with "Velstar"
    And I fill in the "Last Name" input field with "Test"
    And I fill in the "Telephone" input field with "07700900000"


  Scenario: Register stays disabled until the required fields are filled
    Then the "Register" should not be enabled
    And the "marketing consent email" should be displayed


  Scenario: Mismatched passwords are rejected
    When I fill in the "Email address" input field with a unique email, remembering it as "registration email"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm Password" input field with "Different123!"
    And I click on the "Register" button
    Then the "register form" should contain the text "Passwords must match"
    And I should be redirected to the "register" page


  Scenario: A password shorter than 8 characters is rejected
    When I fill in the "Email address" input field with a unique email, remembering it as "registration email"
    And I fill in the "Password" input field with "abc"
    And I fill in the "Confirm Password" input field with "abc"
    And I click on the "Register" button
    Then the "register form" should contain the text "Please ensure your password is at least 8 characters long"
    And I should be redirected to the "register" page


  Scenario: A malformed email address is rejected
    When I fill in the "Email address" input field with "not-an-email"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm Password" input field with "Testing123!"
    And I click on the "Register" button
    Then the "Email address" input should be rejected as invalid
    And I should be redirected to the "register" page


  Scenario: An already registered email address is rejected
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm Password" input field with "Testing123!"
    And I click on the "Register" button
    Then the "register alert" should contain the text "This email address is already registered"


  # Creates a real account (disposable qa-<timestamp>@velstar-test.co.uk
  # address) - staging only, excluded from production runs by its tag.
  @completes-registration
  Scenario: Registering a new account signs the user in to My Account
    When I fill in the "Email address" input field with a unique email, remembering it as "registration email"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm Password" input field with "Testing123!"
    And I click on the "Register" button
    Then I should eventually be redirected to the "account" page
    And the "account welcome" should contain the text "Velstar"
