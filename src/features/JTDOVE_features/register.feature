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



  # Manual cases 217 and 218 (added 2026-10-23): validation only, the forms
  # are never completed (a real application emails JT Dove staff). The
  # business-detail fields only render after the first NEXT, which on these
  # two forms just moves from step 1 to step 2. The self-build form isn't
  # covered: all its required fields sit on the step whose button may be the
  # final submit, so pressing it isn't safe to automate.
  Scenario Outline: The <type> account application requires its business details
    Given I am on the "<page>" page
    And I wait for the page to settle
    When I click on the "Next" button
    Then the "application trading name" input should be rejected as empty
    And the "application mobile" input should be rejected as empty
    And the "application email" input should be rejected as empty
    When I fill in the "application email" input field with "not_an_email@"
    Then the "application email" input should be rejected as invalid
    Examples:
      | type   | page                    |
      | credit | register-credit-account |
      | cash   | register-cash-account   |
