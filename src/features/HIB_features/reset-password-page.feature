@regression
Feature: Resetting the password

  # Covers direct navigation to /reset-password, distinct from
  # logging-in.feature's "Resetting password" scenario which reaches this
  # page via the login page's "Forgotten your password?" link.

  Scenario: Requesting the reset password email with a valid email address
    Given I am on the "reset-password" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with "valid_email_address@test.co.uk"
    And I click on the "SUBMIT" button
    Then I should be presented with a "reset password message" "Thanks! You should receive an email shortly with instructions on how to proceed."


  Scenario Outline: Requesting the reset password email with an invalid email address
    Given I am on the "reset-password" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with "<email>"
    And I click on the "SUBMIT" button
    Then I should be presented with a "validation message" "<message>"

    Examples:
      | email                        | message                            |
      | not_a_correct_email_address@ | Please enter a valid email address |
