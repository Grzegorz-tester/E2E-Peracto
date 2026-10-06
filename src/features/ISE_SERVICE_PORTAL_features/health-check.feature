@regression
Feature: Health check

  # ISE-SP.1 (hosting + configuration). The portal is login-gated, so the
  # sign-in page is the only thing reachable without credentials.

  @smoke
  Scenario: The sign-in page loads
    Given I am on the "login" page
    Then the "Email address" should be displayed
    And the "Password" should be displayed
    And the "Sign In" should be displayed

  Scenario: An unauthenticated visit to the dashboard is sent to sign in
    Given I navigate directly to the path "/"
    Then I should be redirected to the "login" page
