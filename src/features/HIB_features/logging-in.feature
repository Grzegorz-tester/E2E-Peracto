@smoke
@regression
Feature: Login Page


  Scenario: Successful log in to the user's account
    Given I am on the "login" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "home" page


  Scenario: Unsuccessful log in attempt with a wrong password
    Given I am on the "login" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "wrongPassword"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Invalid credentials."


  Scenario: Unsuccessful log in attempt with an unregistered email
    Given I am on the "login" page
    And I dismiss the newsletter popup if present
    When I fill in the "Email address" input field with "not_registered@user.com"
    And I fill in the "Password" input field with "Password123"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Username could not be found."


  Scenario: Resetting password
    Given I am on the "login" page
    And I dismiss the newsletter popup if present
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with "not_a_correct_email_address@"
    And I click on the "SUBMIT" button
    Then I should be presented with a "validation message" "Please enter a valid email address"
    When I fill in the "Email address" input field with "valid_email_address@test.co.uk"
    And I click on the "SUBMIT" button
    Then I should be presented with a "reset password message" "Thanks! You should receive an email shortly with instructions on how to proceed."



