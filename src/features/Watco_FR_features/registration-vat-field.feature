@regression
Feature: Registration - VAT number field (FR)

  # Migrated from P3Playwright watco/tests/account/fr/registration-vat-field.test.ts
  # FR mirror of the UK suite. Registration path is localized
  # (/senregistrer), and unlike UK/IE this market activates accounts
  # immediately rather than requiring email verification.

  Scenario: VAT number field is visible with the correct label, placeholder, and no comment text
    Given I am on the "register" page
    Then the "VAT number" should be displayed
    And the "VAT number" should have attribute "placeholder" with value "FRXX123456789"
    And the "VAT number label" should be displayed
    And the "validation message" should not be displayed
    And the "VAT number comment" should not be displayed

  Scenario: An invalid VAT number is rejected on submit with a validation error
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0600000005"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    And I fill in the "VAT number" input field with "FRA1234567"
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then the "validation message" should be displayed
    And the "validation message" should equal text "Le numéro de TVA entré n'est pas valable. Veuillez entrer un numéro de TVA au format: FRXX123456789."

  Scenario: Registration succeeds with the VAT number left blank
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "0600000006"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then I should be redirected to the "register-confirmed" page
