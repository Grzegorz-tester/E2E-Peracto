@smoke
@regression

Feature: Login Page

  # KOOL's Peracto admin (staging-peracto.kooltech.pub) runs the same
  # Peracto Admin product as Carbon Admin - confirmed live: identical
  # data-testid selectors, routes, and error copy. This project's setup
  # mirrors Carbon Admin's, but uses the "admin" user type/env-var
  # credentials rather than hardcoding a real login in the feature file.
  #
  # CONFIRMED SITE QUIRK (live, 2026-08-19): every interactive button/link
  # tested on this admin frontend (Sign In, Forgotten your password?, Reset,
  # the forgotten-password page's own Sign In link) silently does nothing
  # when force-clicked - the generic "I click on the X" step always forces,
  # so it never triggers navigation here. A real (non-forced) click works
  # every time, so "I click precisely on the X" is used throughout this
  # project instead of the generic force-clicking step. Worth keeping in
  # mind for every future KOOL_admin feature, not just this one.

  @smoke
  Scenario: Successful log in to the admin account
    Given I am navigating the page as a "admin" user
    Then I should be redirected to the "dashboard" page

  Scenario Outline: Unsuccessful log in attempt
    Given I am on the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click precisely on the "Sign In" button
    Then I should be presented with a "validation message" "<errorMessage>"
    Examples:
      | email                          | password      | errorMessage                 |
      | grzegorz.hajduk@velstar.co.uk  | wrongPassword | Invalid credentials.         |
      | not_registered@user.com        | Password123   | Username could not be found. |

  Scenario: Resetting password
    Given I am on the "login" page
    When I click precisely on the "Forgotten your password?" link
    Then I should be redirected to the "forgotten-password" page

    When I fill in the "Email address" input field with "valid_email_address@test.co.uk"
    And I click precisely on the "Reset" button
    Then I should be presented with a "reset password message" "If you have an account, an email will be generated to reset your password."

  Scenario: Redirection from the forgotten-password page back to the login page
    Given I am on the "forgotten-password" page
    When I click precisely on the "Sign In" button
    Then I should be redirected to the "login" page
