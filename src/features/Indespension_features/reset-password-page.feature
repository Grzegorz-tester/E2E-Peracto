@regression
Feature: Resetting the password

  Scenario: Requesting the reset password email with the registered email address
    Given I am on the "reset-password" page
    When I fill in the "Email address" input field with "<string>"
    And I click on the "SUBMIT" button

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