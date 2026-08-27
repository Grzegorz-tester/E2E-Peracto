@regression
@completes-registration
Feature: Account profile - NIP-EU save (PL)

  # New coverage, added to bring PL to parity with the other Watco markets
  # after UK's WAT-305 was fixed (see Watco_features/account-profile-vat-save.feature
  # for the full story). Confirmed live (2026-08-26): PL's account-profile
  # form (form[name='user_profile']) has the SAME three required fields as
  # every other market checked so far - Company, Job function, Industry
  # sector - that registration never collects, so a freshly-registered
  # account always loads the profile page with them blank and the
  # browser's native HTML5 `required` validation silently blocks the Save
  # submit until they're filled. Confirmed filling all three (plus the
  # NIP-EU field) fires a real POST to /konto/profil-klienta and the new
  # NIP-EU value persists correctly across a reload.
  #
  # PL is the one market with TWO separate tax-ID fields (see
  # registration-vat-field.feature) - NIP (domestic) and NIP-EU (the field
  # that drives VAT treatment, reusing every other market's single "VAT
  # number" element key/input id). This scenario edits NIP-EU only,
  # matching every other market's single-field persistence test; NIP
  # itself is left untouched throughout.
  #
  # Job function and Industry sector are selected by ordinal ("2nd" = the
  # first REAL option, since index 0/"1st" is the "Wybierz opcję"
  # placeholder - confirmed live the hard way: using "1st" silently left
  # both fields on the placeholder, which is exactly as unselected as
  # leaving them untouched, and the required-field block below fired
  # anyway despite the steps "succeeding"), not by their (Polish-language)
  # option text - matching this market's own established convention for
  # Title in registration-vat-field.feature, since the exact wording of an
  # arbitrary required-field-filler option isn't worth hardcoding/translating.
  #
  # Uses a throwaway freshly-registered account rather than the shared
  # "account test user with vat" account, since this scenario's whole
  # point is to mutate a saved NIP-EU number, and a bug here should never
  # risk leaving a shared account in an unexpected state for other tests.

  Scenario: Editing the NIP-EU number and saving persists the new value
    Given I am on the "register" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "500000011"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "PL1111111111"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "PL1111111111"

    When I fill in the "VAT number" input field with "PL9999999999"
    # Required by the profile form but not collected at registration - left
    # blank, the browser's native required-field validation silently blocks
    # the submit below (see the note above).
    And I fill in the "Company" input field with "Velstar Test Sp. z o.o."
    And I select the "2nd" option from the "Job function" dropdown
    And I select the "2nd" option from the "Industry sector" dropdown
    And I click on the "Save details" button, removing the "cookie preference centre overlay" overlay if it interferes
    # Save details submits a real POST that redirects back to this same
    # page - without this, "I reload the page" right below can race that
    # in-flight redirect (confirmed live: reproduced twice via the full
    # suite, never via a bare standalone script with its own settle delay).
    And I wait for the page to settle
    And I reload the page
    Then the "VAT number" should equal the value "PL9999999999"
