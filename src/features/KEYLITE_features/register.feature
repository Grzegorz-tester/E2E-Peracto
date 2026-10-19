@regression
Feature: Register page

  # WARNING: unlike MIPA (a "Request an Account" sales enquiry form), a
  # real self-serve account gets created here every time this runs -
  # confirmed live 2026-09-06: submitting a real unique email logs the new
  # user straight in (no email verification step). Fine per this repo's
  # staging rules, but keep this to one scenario, same discipline as the
  # purchase-journey scenarios that place a real order each run.
  #
  Scenario: Registering a new account logs the user straight in
    Given I am on the "register" page
    And I dismiss the newsletter popup if present
    When I fill in the "Register First Name" input field with "Velstar"
    And I fill in the "Register Last Name" input field with "Test"
    And I fill in the "Register email" input field with a unique guest email
    And I fill in the "Register phone" input field with "07911123456"
    And I fill in the "Register password" input field with "Testing123!"
    And I fill in the "Register confirm password" input field with "Testing123!"
    And I click on the "Register submit" button
    And I wait for the page to settle
    Then I should be redirected to the "account" page
