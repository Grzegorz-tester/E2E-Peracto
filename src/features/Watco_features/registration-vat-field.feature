@regression
Feature: Registration - VAT number field

  # Migrated from P3Playwright watco/tests/account/uk/registration-vat-field.test.ts
  # WAT-335 - VAT registration number field, account registration (UK).
  # Every selector here was already live-verified in the source repo
  # (staging, 2026-08-05) - not re-discovered from scratch, but should
  # still be confirmed with a real run since this repo's step timing
  # differs from the source's own Playwright Test assertions.

  Scenario: VAT number field is visible with the correct label, placeholder, and no comment text
    Given I am on the "register" page
    Then the "VAT number" should be displayed
    And the "VAT number" should have attribute "placeholder" with value "GB123456789"
    And the "VAT number label" should be displayed
    And the "validation message" should not be displayed
    And the "VAT number comment" should not be displayed

  Scenario: An invalid VAT number is rejected on submit with a validation error
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "Mr" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "07700900002"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    And I fill in the "VAT number" input field with "GB12345"
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then the "validation message" should be displayed
    And the "validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format GB123456789."

  # CONFIRMED SITE BEHAVIOUR: after a failed submit, the password fields
  # (only) are cleared server-side - the source re-fills every field
  # rather than assuming the previous scenario's values survived, and so
  # does this one (each Scenario also gets a fresh browser context here
  # regardless, unlike the source's single chained test).
  Scenario: Registration succeeds with the VAT number left blank
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "Mr" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "07700900002"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then I should be redirected to the "register-confirmed" page
