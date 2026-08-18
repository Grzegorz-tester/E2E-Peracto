@regression
Feature: Registration - NIP and NIP-EU fields (PL)

  # Migrated from P3Playwright watco/tests/account/pl/registration-vat-field.test.ts
  #
  # PL is the ONE market with genuinely TWO separate fields instead of a
  # single VAT number field:
  # - NIP - the domestic Polish tax ID (label "NIP", placeholder
  #   "0123456789"). Has no comment text.
  # - NIP-EU - the EU VAT number, reusing the same input id every other
  #   market uses for its single VAT field (label "NIP-EU", placeholder
  #   "PL1234567890"). Has a comment explaining its purpose.

  Scenario: Both fields are visible with the correct label/placeholder; NIP-EU has a comment, NIP does not
    Given I am on the "register" page
    Then the "NIP number" should be displayed
    And the "NIP number" should have attribute "placeholder" with value "0123456789"
    And the "NIP number label" should be displayed
    And the "NIP validation message" should not be displayed

    And the "VAT number" should be displayed
    And the "VAT number" should have attribute "placeholder" with value "PL1234567890"
    And the "VAT number label" should be displayed
    And the "validation message" should not be displayed
    And the "VAT number comment" should equal text "Jeśli jesteś podatnikiem VAT w UE, podaj numer z przedrostkiem PL — zastosujemy stawkę 0% dla transakcji wewnątrzwspólnotowych."

  Scenario: An invalid NIP is rejected on submit with its own format-specific error
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "500000005"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    And I fill in the "NIP number" input field with "123"
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then the "NIP validation message" should be displayed
    And the "NIP validation message" should equal text "Wprowadzony numer NIP jest nieprawidłowy. Wprowadź numer NIP w formacie 1234567890."

  Scenario: Registration succeeds with both fields left blank
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "2nd" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "500000006"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click precisely on the "Marketing agreement" element, dismissing the "close cookie preference centre" if it interferes
    Then the "Register" should be enabled
    And I click on the "Register" button, dismissing the "close cookie preference centre" if it interferes
    Then I should be redirected to the "register-confirmed" page
