@Andy_Thornton_regression
Feature: Resetting the password

  Scenario: Requesting the reset password email with the registered email address
    Given I am on the "reset-password" page
    When I fill in the "Email address" input field with "grzegorz.hajduk+andythornton@velstar.co.uk"
    And I click on the "Submit" button
    Then I should be presented with a "reset password message" "You should receive an email shortly with instructions on how to proceed."

  Scenario: Requesting the reset password email with a malformed email address
    Given I am on the "reset-password" page
    When I fill in the "Email address" input field with "not_a_correct_email_address@"
    And I click on the "Submit" button
    Then the "Email address" input should be rejected as invalid
