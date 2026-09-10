@regression
Feature: Login Page

  # "Successful log in" is blocked pending a real Andy Thornton test account:
  # the generic LOGGED_IN_EMAIL/PASSWORD isn't registered on this storefront,
  # and /register can't be scripted around (reCAPTCHA) - see .env.example.
  Scenario: Successful log in to the user's account
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    Then the "Sign Out button" should be displayed
    And the "Sign In button" should not be displayed

  Scenario Outline: Unsuccessful log in attempt into the user's account
    Given I am on the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "<errorMessage>"
    Examples:
      | email                            | password      | errorMessage                 |
      | grzegorz.hajduk+andythornton@velstar.co.uk | wrongPassword | Invalid credentials.         |
      | not_registered@user.com          | Password123!  | Username could not be found. |

  Scenario: Resetting password
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
