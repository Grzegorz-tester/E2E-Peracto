@regression
Feature: Login Page and password reset

  # Rewritten against the live storefront - the previous version was cloned
  # from HIB and never adapted: it expected a post-login redirect to "home",
  # but this project's own env/Indespension.env sets LOGIN_SUCCESS_URL to
  # /account, confirmed live (a real login lands on /account, not /). The
  # reset-password flow (previously its own near-empty reset-password-page
  # .feature, with no assertions) is folded in here instead, matching how
  # Insinkerator structures its own logging-in.feature.

  @smoke
  Scenario: Successful log in to the user's account
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page


  Scenario: Unsuccessful log in with a wrong password for a real account
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "wrongPassword"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Invalid credentials."


  Scenario: Unsuccessful log in with an unregistered email
    Given I am on the "login" page
    When I fill in the "Email address" input field with "not_registered@user.com"
    And I fill in the "Password" input field with "Password123"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Username could not be found."


  # The live login form has no client-side validation UI of its own for
  # empty fields - both inputs rely entirely on the browser's native
  # required/type=email validity state (confirmed live: submitting empty
  # leaves the page on /login with the email input's validity.valueMissing
  # true and no rendered error), so this asserts that native state directly
  # rather than a rendered message that doesn't exist.
  Scenario: Submitting the login form with an empty email field is rejected natively
    Given I am on the "login" page
    When I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button
    Then the "Email address" input should be rejected as empty


  Scenario: Submitting the login form with an empty password field is rejected natively
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I click on the "Sign In" button
    Then the "Password" input should be rejected as empty


  Scenario: Resetting password
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with "not_a_correct_email_address@"
    Then the "Email address" input should be rejected as invalid
    When I fill in the "Email address" input field with the "logged in" user's email
    And I click on the "Submit" button
    Then I should be presented with a "reset password message" "You should receive an email shortly with instructions on how to proceed."
