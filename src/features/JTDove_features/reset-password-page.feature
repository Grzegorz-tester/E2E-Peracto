
Feature: Resetting the password

  Scenario: Requesting the reset password email with the registered email address
    Given the user is on the reset password page
    When the user enters his email
    And clicks the Submit button

#
#  Scenario Outline: Requesting the reset password email with email address that is not registered
#    Given the user is on the reset password page
#    When the user enters a wrong email address <email>
#    And clicks the Submit button
#    Then he should be presented with an error message <message>
#    Examples:
#      | email            | message                            |
#      |                  | Please enter your email address    |
#      | not_valid_email@ | Please enter a valid email address |