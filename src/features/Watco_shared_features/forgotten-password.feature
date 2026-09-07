@regression
Feature: Forgotten password

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. Submitting the shared "account test user 1" email
  # redirects to a "check your email" confirmation page - this only
  # requests the reset, it never completes one, so the shared account's
  # real password is untouched.

  Scenario: Requesting a password reset redirects to the check-your-email confirmation
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I click on the "Forgotten password link" link
    Then I should be redirected to the "forgotten" page

    When I fill in the "forgotten password email" input field with the "account test user 1" user's email
    And I click on the "forgotten password submit" button
    Then I should be redirected to the "check-email" page
