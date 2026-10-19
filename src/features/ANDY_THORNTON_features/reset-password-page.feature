@regression
Feature: Resetting the password

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): see
  # PDP.feature - an undismissed Cookiebot banner sits over the Submit
  # button on a fresh consent-less context.
  #
  # BLOCKED UNDER AUTOMATION (live, production/www.andythornton.com,
  # 2026-09-14): submitting this form under Playwright surfaces
  # reCAPTCHA's own "ERROR for site owner: Invalid domain for site key"
  # badge, and the success message never appears (20s timeout) - but the
  # user confirmed the identical form submission succeeds normally
  # ("Thank you! You should receive an email shortly...") in a real
  # browser, so this isn't a real site misconfiguration, it's reCAPTCHA
  # itself blocking the automated context - the same class of limitation
  # already documented for /register in logging-in.feature ("/register
  # can't be scripted around (reCAPTCHA)"). Expected to stay red under
  # automation; not a test/mapping gap to chase further.

  Scenario: Requesting the reset password email with the registered email address
    Given I am on the "reset-password" page
    And I click on the "Allow all cookies" button if present
    When I fill in the "Email address" input field with "grzegorz.hajduk+andythornton@velstar.co.uk"
    And I click on the "Submit" button
    Then I should be presented with a "reset password message" "You should receive an email shortly with instructions on how to proceed."

  Scenario: Requesting the reset password email with a malformed email address
    Given I am on the "reset-password" page
    And I click on the "Allow all cookies" button if present
    When I fill in the "Email address" input field with "not_a_correct_email_address@"
    And I click on the "Submit" button
    Then the "Email address" input should be rejected as invalid
