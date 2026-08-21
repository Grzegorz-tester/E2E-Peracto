@regression
Feature: Register page

  # Confirmed live (2026-08-21): a successful registration signs the user
  # in immediately and redirects straight to "account" - there is no
  # separate confirmation step. Uses a unique guest email each run (the
  # same generic step checkout.feature/logged-in-purchase-journey.feature
  # use) so this can be re-run on staging without colliding with a
  # previous run's account.

  Background:
    Given I am on the "home" page

  Scenario: "Register" in the header redirects to the registration form
    When I click on the "Register" element
    Then I should be redirected to the "register" page
    And the "register form" should be displayed

  Scenario: Successful registration signs the user in
    Given I am on the "register" page
    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Register email" input field with a unique guest email
    And I fill in the "Register phone" input field with "07377777777"
    And I fill in the "Register password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Register submit button" button
    Then I should be redirected to the "account" page

  Scenario: Registering with an invalid email address is rejected
    Given I am on the "register" page
    When I fill in the "Register email" input field with "not-an-email"
    Then the "Register email" input should be rejected as invalid

  Scenario: Registering with missing required fields is rejected
    Given I am on the "register" page
    When I click on the "Register submit button" button
    Then the "First name" input should be rejected as empty
