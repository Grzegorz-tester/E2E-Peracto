@regression
Feature: Login Page

  # UPDATED (2026-09-14): a real Andy Thornton production account now
  # exists (grzegorz.hajduk@velstar.co.uk, credentials in
  # ANDY_THORNTON_PROD_LOGGED_IN_EMAIL/PASSWORD) - "Successful log in" is
  # no longer blocked. /register still can't be scripted around
  # (reCAPTCHA), so this account was registered manually rather than by
  # this suite.
  Scenario: Successful log in to the user's account
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    Then the "Sign Out button" should be displayed
    And the "Sign In button" should not be displayed

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): see
  # PDP.feature - an undismissed Cookiebot banner intercepts the login
  # form on a fresh consent-less context (confirmed via a native "Please
  # fill out this field" browser tooltip - the fill never reached the
  # real input).
  #
  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): the
  # "wrong password" row must use a genuinely REGISTERED email - it
  # previously used the "+andythornton" plus-aliased address, which isn't
  # actually registered on production (only the bare
  # grzegorz.hajduk@velstar.co.uk is, per ANDY_THORNTON_PROD_LOGGED_IN_
  # EMAIL) - the real site correctly returned "Username could not be
  # found." instead of "Invalid credentials.", which is right for an
  # unregistered address but wrong for what this row is meant to test.
  Scenario Outline: Unsuccessful log in attempt into the user's account - "<errorMessage>"
    Given I am on the "login" page
    And I click on the "Allow all cookies" button if present
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "<errorMessage>"
    Examples:
      | email                            | password      | errorMessage                 |
      | grzegorz.hajduk@velstar.co.uk    | wrongPassword | Invalid credentials.         |
      | not_registered@user.com          | Password123!  | Username could not be found. |

  Scenario: Resetting password
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
