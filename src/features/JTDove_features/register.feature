@regression
Feature: Registration and account applications

  # New coverage (2026-10-05). JT Dove has no self-serve "create a login"
  # sign-up: /register activates online access for an EXISTING branch
  # account (account number required), and new customers apply for a
  # credit, cash or self-build account via multi-step application forms.
  # Nothing here is ever submitted - an application goes to JT Dove's
  # accounts team and activation needs a real account number.

  Scenario: Online access form asks for an existing account number
    Given I am on the "register" page
    And I wait for the page to settle
    Then the "register form" should be displayed
    And the "Account number" should be displayed
    And the "First name" should be displayed
    And the "Last name" should be displayed
    And the "Email" should be displayed
    And the "Telephone" should be displayed
    And the "Password" should be displayed
    And the "Confirm password" should be displayed


  Scenario: Online access form won't submit without an account number
    Given I am on the "register" page
    And I wait for the page to settle
    When I click on the "Submit registration" button
    Then the "Account number" input should be rejected as empty
    And I should be redirected to the "register" page


  Scenario Outline: The <type> account application starts on its first step
    Given I am on the "<page>" page
    And I wait for the page to settle
    Then the "application title" should be displayed
    And the "application first step" should be displayed
    And I should see "3" "application step circles" displayed
    And the "Next" should be displayed
    Examples:
      | type       | page                        |
      | credit     | register-credit-account     |
      | cash       | register-cash-account       |
      | self build | register-self-build-account |
