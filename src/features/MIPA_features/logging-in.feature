@smoke
@MIPA_regression
Feature: Login Page


  # Used to hardcode "logged-in-user@example.com" as a literal string - same
  # dead account as the wrong-password scenario below: confirmed live via
  # the auth API, this email returns 401 "Username could not be found."
  # regardless of password, so this could never redirect anywhere. Fixed
  # by sourcing the real account from users.json/env vars.
  Scenario: Successful log in to the user's account
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "home" page


  # Split out of the old Scenario Outline - the "wrong password" row used
  # to hardcode "logged-in-user@example.com" as a literal string, which is
  # not (or is no longer) a real account: confirmed live, the auth API
  # itself returns 401 "Username could not be found." for that email
  # regardless of password, so the row could never see "Invalid
  # credentials." - not a test timing issue. Fixed by sourcing the real
  # account from users.json/env vars, same as the rest of the suite.
  Scenario: Unsuccessful log in with a wrong password for a real account
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "wrongPassword"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Invalid credentials."


  Scenario: Unsuccessful log in with an unregistered email
    Given I am on the "login" page
    When I fill in the "Email address" input field with "not_registered@user.com"
    And I fill in the "Password" input field with "Password123"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Username could not be found."


  Scenario: Resetting password
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with "not_a_correct_email_address@"
    And I click on the "SUBMIT" button
    Then I should be presented with a "validation message" "Please enter a valid email address"
    When I fill in the "Email address" input field with "valid_email_address@test.co.uk"
    And I click on the "SUBMIT" button
    Then I should be presented with a "reset password message" "Thanks! You should receive an email shortly with instructions on how to proceed."



