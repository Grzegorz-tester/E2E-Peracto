@regression
Feature: Login and password reset

  Background:
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: Successful login with valid credentials
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

  Scenario: Submitting an empty login form is rejected by client-side validation
    When I click on the "Sign In" button
    Then the "Email address" input should be rejected as empty
    And the "Login alert" should not be displayed

  Scenario: User cannot log in with a wrong password
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "WrongPassword123!"
    And I click on the "Sign In" button
    Then the "Login alert" should contain the text "Invalid credentials."
    And I should be redirected to the "login" page

  Scenario: User can request a password reset via the Forgotten password link
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I click on the "Send me the link" button
    Then the "Password reset success" should be displayed
