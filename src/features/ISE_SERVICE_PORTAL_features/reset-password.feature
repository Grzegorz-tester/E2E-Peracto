@regression
Feature: Forgotten password

  # ISE-SP.8. Uses an address with no account, so no real reset email is
  # sent and the real role accounts never hit the 5-minute request
  # cooldown. The confirmation copy is deliberately neutral (it doesn't
  # reveal whether the account exists), which is what this asserts.
  # Link expiry (1 hour, per Settings) needs a real inbox - manual only.

  Scenario: The Forgotten password link opens the reset form
    Given I am on the "login" page
    When I click on the "Forgotten your password" link
    Then I should be redirected to the "forgot-password" page
    And the "Email address" should be displayed

  Scenario: Requesting a reset shows a neutral confirmation
    Given I am on the "forgot-password" page
    When I fill in the "Email address" input field with "velstar-test-no-account@velstar.co.uk"
    And I click on the "Send reset link" button
    Then the "reset confirmation" should contain the text "If an account exists with that email address"
