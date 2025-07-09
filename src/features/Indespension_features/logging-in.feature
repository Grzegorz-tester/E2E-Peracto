@smoke
@regression
Feature: Login Page


  Scenario Outline: Successful log in to the user's account
    Given I am on the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be redirected to the "home" page
    Examples:
      | email            | password   |
      | g.hajduk@9xb.com | Testing123 |


  Scenario Outline: Unsuccessful log in attempt into the user's account
    Given I am on the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "<errorMessage>"
    Examples:
      | email                   | password      | errorMessage                 |
      | g.hajduk@9xb.com        | wrongPassword | Invalid credentials.         |
      | not_registered@user.com | Testing123    | Username could not be found. |


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



