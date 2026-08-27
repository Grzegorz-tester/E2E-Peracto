@regression
@completes-registration
Feature: Account profile - VAT number save (BE-NL)

  # BE-NL mirror of the UK suite - see that file's docblock for the full
  # WAT-305 background. This is NOT a site bug: the account-profile form
  # (form[name='user_profile']) has three required fields - Company, Job
  # function, Industry sector - that registration never collects, so a
  # freshly-registered account always loads the profile page with them
  # blank. Left blank, the browser's native HTML5 `required` validation
  # silently blocks the form submit client-side (no request of any kind
  # fires). Confirmed live (2026-08-26): identical pattern to UK - same
  # three required fields, same field IDs, same silent-block behaviour.
  # Filling all three before clicking "Save details" fires a real POST to
  # /mijn-account/persoonlijke-informatie and the new VAT number persists
  # correctly across a reload.
  #
  # Uses a throwaway freshly-registered account rather than the shared
  # "account test user with vat" account, since this scenario's whole
  # point is to mutate a saved VAT number, and a bug here should never
  # risk leaving a shared account in an unexpected state for other tests.

  Scenario: Editing the VAT number and saving persists the new value
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0470000010"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "BE0123456789"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "BE0123456789"

    When I fill in the "VAT number" input field with "BE0987654321"
    # Required by the profile form but not collected at registration - left
    # blank, the browser's native required-field validation silently blocks
    # the submit below (see the WAT-305 note above).
    And I fill in the "Company" input field with "Velstar Test BV"
    And I select the "Gebouwbeheerder" option from the "Job function" dropdown
    And I select the "Bouw/BTP" option from the "Industry sector" dropdown
    And I click on the "Save details" button, removing the "cookie preference centre overlay" overlay if it interferes
    And I reload the page
    Then the "VAT number" should equal the value "BE0987654321"
