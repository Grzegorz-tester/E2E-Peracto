@regression
Feature: Resetting the password

  Scenario: Reaching the reset password page from login
    Given I am on the "login" page
    And I dismiss the newsletter popup if present
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page

  # Confirmed live 2026-09-06: a malformed email is blocked by native
  # HTML5 validation (type="email"), not a custom on-page message.
  Scenario: Requesting a reset with an invalid email format is rejected
    Given I am on the "reset-password" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with "not-a-valid-email"
    And I click on the "SUBMIT" button
    Then the "Email address" input should be rejected as invalid

  Scenario: Requesting a reset with a valid email format shows a success state
    Given I am on the "reset-password" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with "valid_email_address@test.co.uk"
    And I click on the "SUBMIT" button
    Then the "reset password success" should be displayed
