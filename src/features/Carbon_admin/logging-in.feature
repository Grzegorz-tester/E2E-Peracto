@smoke
@regression

Feature: Login Page

  # Every Peracto Admin tenant (KOOL, Indespension, Carbon Admin, ...) runs
  # the same underlying product - confirmed live across multiple projects:
  # identical data-testid selectors, routes, nav structure and error copy.
  # This feature (like the rest of this shared Carbon_admin folder, the
  # original boilerplate most Peracto admin projects are set up from) is
  # reused as-is across every such project via each project's
  # own env/<Project>_ADMIN.env + config/<Project>_ADMIN_config/ - only the
  # host URL, credentials and mapping/route specifics differ per project,
  # never the scenarios themselves. Uses the "admin" user type/env-var
  # credentials rather than hardcoding a real login in the feature file.
  #
  # CONFIRMED SITE QUIRK (live, 2026-08-19, re-confirmed across multiple
  # Peracto admin tenants): every interactive button/link tested on this
  # admin frontend (Sign In, Forgotten your password?, Reset, the
  # forgotten-password page's own Sign In link) silently does nothing when
  # force-clicked - the generic "I click on the X" step always forces, so it
  # never triggers navigation here. A real (non-forced) click works every
  # time, so "I click precisely on the X" is used throughout this whole
  # shared folder instead of the generic force-clicking step.
  #
  # CONFIRMED (live, 2026-08-19): the "wrong password" case below fills the
  # email field with the CONFIGURED "admin" user's own real email (via
  # users.json/env vars), not a hardcoded address - which real email exists
  # differs per tenant (e.g. Carbon's real admin isn't
  # grzegorz.hajduk@velstar.co.uk), so a hardcoded address would wrongly hit
  # "Username could not be found." on some tenants instead of the intended
  # "Invalid credentials." for a real-account-wrong-password attempt.
  #
  # CONFIRMED GAP (live, 2026-08-19): Carbon Admin's forgotten-password form
  # is reCAPTCHA-protected server-side ("Recaptcha token not in header"),
  # unlike KOOL's and Indespension's - not something headless automation can
  # solve, so "Resetting password" is expected to fail there specifically.
  # Confirmed live rather than assumed; not a selector or setup mistake.

  @smoke
  Scenario: Successful log in to the admin account
    Given I am navigating the page as a "admin" user
    Then I should be redirected to the "dashboard" page

  Scenario: Unsuccessful log in attempt with a real account's wrong password
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "admin" user's email
    And I fill in the "Password" input field with "wrongPassword"
    And I click precisely on the "Sign In" button
    Then I should be presented with a "validation message" "Invalid credentials."

  Scenario: Unsuccessful log in attempt with an unregistered email
    Given I am on the "login" page
    When I fill in the "Email address" input field with "not_registered@user.com"
    And I fill in the "Password" input field with "Password123"
    And I click precisely on the "Sign In" button
    Then I should be presented with a "validation message" "Username could not be found."

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
