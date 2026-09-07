@regression
Feature: Change password

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. Deliberately only exercises the mismatch-validation path,
  # never a real matching new/confirm pair - completing a real change
  # would invalidate the shared test account's password stored in every
  # environment's credentials, breaking every other scenario that logs in
  # as it.

  Scenario: Submitting mismatched new and confirm passwords shows a validation error
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page

    When I am on the "change-password" page
    And I fill in the "new password" input field with "MismatchPassword123!"
    And I fill in the "confirm new password" input field with "DifferentPassword456!"
    And I click on the "Save new password" button
    Then the "password mismatch error" should be displayed
