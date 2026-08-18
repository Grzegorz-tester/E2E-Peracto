@regression
Feature: Registration - VAT number field (DE)

  # Migrated from P3Playwright watco/tests/account/de/registration-vat-field.test.ts
  # DE mirror of the UK suite, but unlike UK/IE/FR this market DOES show
  # a business-customer comment below the field.

  Scenario: VAT number field is visible with the correct label, placeholder, and business-customer comment
    Given I am on the "register" page
    Then the "VAT number" should be displayed
    And the "VAT number" should have attribute "placeholder" with value "DE123456789 oder ATU12345678"
    And the "VAT number label" should be displayed
    And the "validation message" should not be displayed
    And the "VAT number comment" should equal text "Durch die Angabe der USt-IdNr. weisen Sie sich bei uns als Geschäftskunde aus. Beispiel: DE123456789"

  Scenario: An invalid VAT number is rejected on submit with a validation error
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "017000000005"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    And I fill in the "VAT number" input field with "DE12"
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then the "validation message" should be displayed
    And the "validation message" should equal text "Die eingegebene USt-IdNr. ist ungültig. Bitte geben Sie eine Umsatzsteuer-Identifikationsnummer im Format DE123456789 ein"

  Scenario: Registration succeeds with the VAT number left blank
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "017000000006"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then I should be redirected to the "register-confirmed" page
