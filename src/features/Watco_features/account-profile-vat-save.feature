@regression
Feature: Account profile - VAT number save

  # Migrated from P3Playwright watco/tests/account/uk/account-profile-vat-save.test.ts
  #
  # KNOWN FAILING TEST - WAT-305.
  #
  # CONFIRMED SITE BUG (staging, confirmed live in the source repo,
  # 2026-08-06): editing the VAT number on /account/profile and clicking
  # "Save details" does NOT persist the change. No request to any
  # profile-save endpoint fires at all (checked via page.on('request') in
  # the source repo - only analytics/tracking POSTs appear), and the field
  # silently reverts to its previous value on reload. This scenario is
  # written against the CORRECT/expected behaviour, matching this repo's
  # convention for confirmed bugs - it must stay red until fixed, not be
  # softened to match today's broken behaviour.
  #
  # Uses a throwaway freshly-registered account rather than the shared
  # "account test user with vat" account, since this scenario's whole
  # point is to mutate a saved VAT number, and a bug here should never
  # risk leaving a shared account in an unexpected state for other tests.

  Scenario: Editing the VAT number and saving persists the new value
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "Mr" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "07700900123"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "GB111111111"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "GB111111111"

    When I fill in the "VAT number" input field with "GB222222222"
    And I click on the "Save details" button
    And I reload the page
    Then the "VAT number" should equal the value "GB222222222"
