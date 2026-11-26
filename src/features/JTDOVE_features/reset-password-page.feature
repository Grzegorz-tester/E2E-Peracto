@regression
Feature: Resetting the password

  # Rewritten 2026-10-05 - the old version used step text that had no step
  # definition at all ("Given the user is on the reset password page").

  Scenario: An invalid email address is held back by the browser
    Given I am on the "reset-password" page
    And I wait for the page to settle
    When I fill in the "Email address" input field with "not_an_email@"
    And I click on the "Submit" button
    Then the "Email address" input should be rejected as invalid


  # Manual regression case 42 (added 2026-10-22).
  Scenario: An empty email address is held back by the browser
    Given I am on the "reset-password" page
    And I wait for the page to settle
    When I click on the "Submit" button
    Then the "Email address" input should be rejected as empty


  # Was red from 2026-10-05 as "no confirmation shown". Rechecked live
  # 2026-11-23 on staging and 4-4-0: the page does show "Thank you! You
  # should receive an email shortly...", in reset-password-form__success
  # (the mapping had reset-password-form__success-text, which JT Dove doesn't
  # render). Uses a Velstar-owned address so no real customer is emailed.
  @smoke
  Scenario: Requesting a reset link confirms the request was sent
    Given I am on the "reset-password" page
    And I wait for the page to settle
    When I fill in the "Email address" input field with "velstar.qa.reset@velstar.co.uk"
    And I click on the "Submit" button
    Then the "reset password message" should be displayed within "15" seconds
