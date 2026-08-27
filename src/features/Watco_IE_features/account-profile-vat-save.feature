@regression
@completes-registration
Feature: Account profile - VAT number save (IE)

  # IE mirror of the UK suite - same platform/mechanics, own domain and
  # VAT format (IE9999999L). See Watco_features/account-profile-vat-save.feature
  # (UK) for the base scenario this was adapted from.
  #
  # The account-profile form (form[name='user_profile']) has three
  # required fields - Company, Job function, Industry sector - that
  # registration never collects, so a freshly-registered account always
  # loads the profile page with them blank. The browser's native HTML5
  # `required` validation silently blocks the form submit client-side
  # when they're empty (no request of any kind fires, no visible
  # on-page error either, since it's a native browser constraint
  # bubble, not an app-rendered validation message). Confirmed live
  # (2026-08-26, same as UK): filling all three before clicking "Save
  # details" fires a real POST to /account/profile and the new VAT
  # number persists correctly across a reload.
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
    And I fill in the "Telephone" input field with "0870000005"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "IE1111111L"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "IE1111111L"

    When I fill in the "VAT number" input field with "IE2222222L"
    # Required by the profile form but not collected at registration - left
    # blank, the browser's native required-field validation silently blocks
    # the submit below (see the note above).
    And I fill in the "Company" input field with "Velstar Test Ltd"
    And I select the "Facilities Manager" option from the "Job function" dropdown
    And I select the "Building/construction" option from the "Industry sector" dropdown
    And I click on the "Save details" button
    And I reload the page
    Then the "VAT number" should equal the value "IE2222222L"
