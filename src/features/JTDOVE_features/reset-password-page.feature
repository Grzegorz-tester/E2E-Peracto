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


  # KNOWN SITE ISSUE (confirmed live 2026-10-05): submitting a valid email
  # POSTs /reset-password successfully (HTTP 200) but the page shows no
  # confirmation at all - the form just sits there, so the customer can't
  # tell whether anything happened. The shared Peracto component has a
  # reset-password-form__success-text element for exactly this (other
  # Peracto storefronts render it); JT Dove never does. Expected to stay red
  # until that's fixed. Uses a Velstar-owned address so no real customer is
  # emailed.
  Scenario: Requesting a reset link confirms the request was sent
    Given I am on the "reset-password" page
    And I wait for the page to settle
    When I fill in the "Email address" input field with "velstar.qa.reset@velstar.co.uk"
    And I click on the "Submit" button
    Then the "reset password message" should be displayed within "15" seconds
