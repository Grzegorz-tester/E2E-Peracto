@regression
Feature: Login and logout

  # ISE-SP.7 (single login screen, role-based landing) and ISE-SP.9
  # (session handling). Every role currently lands on the dashboard; what
  # differs per role is the menu (see access-control.feature).
  #
  # CONFIRMED live (2026-10-06): the login form is throttled - about 3
  # failed attempts locks that account for ~15 minutes ("Too many failed
  # login attempts, please try again in N minutes."). The wrong-password
  # scenario therefore uses an address that has no account, never one of
  # the real role accounts, or a single run (plus RETRY) would lock out the
  # account every other scenario depends on.

  @smoke
  Scenario Outline: A "<user>" user can sign in and lands on the dashboard
    Given I am navigating the page as a "<user>" user
    Then I should be redirected to the "dashboard" page
    And the "welcome message" should contain the text "Welcome back"

    Examples:
      | user      |
      | owner     |
      | admin     |
      | manager   |
      | engineer  |
      | developer |

  Scenario: Submitting an empty login form is rejected by client-side validation
    Given I am on the "login" page
    When I click on the "Sign In" button
    Then the "Email address" input should be rejected as empty
    And I should be redirected to the "login" page

  Scenario: Signing in with an unknown account is rejected
    Given I am on the "login" page
    When I fill in the "Email address" input field with "velstar-test-no-account@velstar.co.uk"
    And I fill in the "Password" input field with "WrongPassword123!"
    And I click on the "Sign In" button
    Then the "login alert" should contain the text "Invalid credentials."
    And I should be redirected to the "login" page

  Scenario: Logging out ends the session
    Given I am navigating the page as a "owner" user
    When I click on the "Menu" element
    And I click on the "Logout menu link" link
    Then I should be redirected to the "login" page
    When I navigate directly to the path "/"
    Then I should be redirected to the "login" page
