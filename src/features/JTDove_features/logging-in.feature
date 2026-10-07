@smoke
@regression
Feature: Login Page

  # Rewritten 2026-10-05. Credentials come from JTDOVE_LOGGED_IN_EMAIL /
  # _PASSWORD in .env (via users.json), never the feature file. Error copy
  # confirmed live on staging the same day.

  Scenario: Successful log in to the user's account
    Given I am on the "login" page
    And I wait for the page to settle
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should eventually be redirected to the "account" page
    And the "account welcome" should be displayed


  Scenario: Wrong password is rejected
    Given I am on the "login" page
    And I wait for the page to settle
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "VelstarWrongPassword1!"
    And I click on the "Sign In" button
    Then the "login error" should contain the text "Invalid credentials."


  Scenario: Unknown email address is rejected
    Given I am on the "login" page
    And I wait for the page to settle
    When I fill in the "Email address" input field with "velstar.not.registered@velstar.co.uk"
    And I fill in the "Password" input field with "VelstarWrongPassword1!"
    And I click on the "Sign In" button
    Then the "login error" should contain the text "Username could not be found."


  Scenario: Empty login form is held back by the browser
    Given I am on the "login" page
    And I wait for the page to settle
    When I click on the "Sign In" button
    Then the "Email address" input should be rejected as empty
    And I should be redirected to the "login" page


  Scenario Outline: Login page "<link>" link goes to "<page>"
    Given I am on the "login" page
    And I wait for the page to settle
    When I click on the "<link>" element, retrying until redirected to the "<page>" page
    Examples:
      | link                                     | page                        |
      | Forgotten your password?                 | reset-password              |
      | Have an account but not an online login? | register                    |
      | Start credit account application         | register-credit-account     |
      | Start cash account application           | register-cash-account       |
      | Start self build account application     | register-self-build-account |


  Scenario: Signing out returns the user to a logged-out state
    Given I am navigating the page as a "logged in" user
    And I am on the "account" page
    And I wait for the page to settle
    When I click on the "Sign Out" element
    Then the "Sign In" should be displayed
    When I navigate directly to the path "/account"
    Then I should eventually be redirected to the "login" page
