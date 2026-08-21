@regression
Feature: Registration - VAT number field (IE)

  # Migrated from P3Playwright watco/tests/account/ie/registration-vat-field.test.ts
  # IE mirror of the UK suite - same platform/mechanics, own domain and
  # VAT format (IE9999999L). See Watco_features/registration-vat-field.feature
  # (UK) for the base scenario this was adapted from, including the fixes
  # already found there (marketing-agreement checkbox needs a precise,
  # non-forced click on its label).

  Scenario: VAT number field is visible with the correct label, placeholder, and no comment text
    Given I am on the "register" page
    Then the "VAT number" should be displayed
    And the "VAT number" should have attribute "placeholder" with value "IE9999999L"
    And the "VAT number label" should be displayed
    And the "validation message" should not be displayed
    And the "VAT number comment" should not be displayed

  Scenario: An invalid VAT number is rejected on submit with a validation error
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "Mr" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0870000005"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "IE12"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should be displayed
    And the "validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format IE9999999L."

  Scenario: Registration succeeds with the VAT number left blank
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "Mr" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0870000006"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page
