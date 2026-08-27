@regression
@completes-registration
Feature: Account profile - VAT number save (DE)

  # DE mirror of the UK suite (src/features/Watco_features/account-profile-
  # vat-save.feature) - see that file's docblock for the full WAT-305
  # history (previously misdocumented as a confirmed site bug; actually a
  # test gap - the account-profile form's required fields, not covered by
  # registration, were silently blocking the native form submit).
  #
  # Confirmed live (2026-08-26) that DE has the exact same three required-
  # but-uncollected fields as UK - Company, Job function, Industry sector
  # (same field IDs: user_profile_company/job_function/industry_sector,
  # German-language option labels). Filling them plus editing the VAT
  # number and clicking "Save details" (Speichern) fires a real POST to
  # /kundenkonto/profil and the new VAT number persists across a reload.
  #
  # Job function/Industry sector option text is German and not worth
  # hardcoding - selects the first real option (index 1, skipping the
  # blank placeholder) by ordinal instead, same convention this project's
  # own registration-vat-field.feature already uses for the Title dropdown
  # for exactly this reason.
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
    And I fill in the "Telephone" input field with "07700900123"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "DE111111111"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "DE111111111"

    When I fill in the "VAT number" input field with "DE222222222"
    # Required by the profile form but not collected at registration - left
    # blank, the browser's native required-field validation silently blocks
    # the submit below (see the WAT-305 note above).
    And I fill in the "Company" input field with "Velstar Test Ltd"
    And I select the "2nd" option from the "Job function" dropdown
    And I select the "2nd" option from the "Industry sector" dropdown
    And I click on the "Save details" button, removing the "cookie preference centre overlay" overlay if it interferes
    And I reload the page
    Then the "VAT number" should equal the value "DE222222222"
