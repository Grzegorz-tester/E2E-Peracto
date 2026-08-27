@regression
@completes-registration
Feature: Account profile - VAT number save (FR)

  # FR mirror of the UK suite (WAT-305 - see account-profile-vat-save.feature
  # under Watco_features for the full story). Same underlying Peracto
  # account-profile form (form[name='user_profile']) with the same three
  # required-but-not-collected-at-registration fields - Company, Job
  # function, Industry sector - confirmed live here too (2026-08-26):
  # leaving them blank silently blocks the native form submit (no request
  # fires at all), which is what made this look like a broken save endpoint
  # on UK before the required fields were identified. Filling them first
  # fires a real POST to /mon-compte/informations-personnelles and the new
  # VAT number persists correctly across a reload.
  #
  # Registration path is localized (/senregistrer) and, per
  # registration-vat-field.feature's own note, this market activates
  # accounts immediately rather than requiring email verification like
  # UK/IE - login works right after Register redirects to
  # register-confirmed. Title dropdown has no English "Mr"/"Mrs" text, so
  # (matching registration-vat-field.feature's own established convention)
  # this uses the ordinal "2nd" option rather than literal text.
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
    And I fill in the "Telephone" input field with "0600000098"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "FRAB111111111"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "FRAB111111111"

    When I fill in the "VAT number" input field with "FRAB222222222"
    # Required by the profile form but not collected at registration - left
    # blank, the browser's native required-field validation silently blocks
    # the submit below (see the WAT-305 note above).
    And I fill in the "Company" input field with "Velstar Test"
    And I select the "Responsable bâtiment" option from the "Job function" dropdown
    And I select the "Construction/ BTP" option from the "Industry sector" dropdown
    And I click on the "Save details" button
    And I reload the page
    Then the "VAT number" should equal the value "FRAB222222222"
