@regression
Feature: Registration - VAT number field (BE-NL)

  # Migrated from P3Playwright watco/tests/account/benl/registration-vat-field.test.ts
  # Mirrors NL - business-customer comment below the field, identical
  # text to NL's. Field label differs from NL's ("Btw-nummer" vs
  # "Belasting over de toegevoegde waarde") - not asserted directly since
  # "VAT number label" is scoped via label[for=], not text.

  Scenario: VAT number field is visible with the correct placeholder and business-customer comment
    Given I am on the "register" page
    Then the "VAT number" should be displayed
    And the "VAT number" should have attribute "placeholder" with value "BE1234567890"
    And the "VAT number label" should be displayed
    And the "validation message" should not be displayed
    And the "VAT number comment" should equal text "Als u ons een btw-nummer verstrekt, zullen wij voor intracommunautaire transacties een btw-tarief van 0% hanteren"

  Scenario: An invalid VAT number is rejected on submit with a validation error
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0470000005"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "BE12"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should be displayed
    And the "validation message" should equal text "Het ingevoerde btw-nummer is ongeldig. Voer een btw-nummer in met het formaat BE1234567890."

  @completes-registration
  Scenario: Registration succeeds with the VAT number left blank
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0470000006"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page
