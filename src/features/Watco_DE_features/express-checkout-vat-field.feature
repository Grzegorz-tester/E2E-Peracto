@regression
Feature: Express Checkout - VAT number field (DE)

  # Migrated from P3Playwright watco/tests/basket-checkout/de/express-checkout-vat-field.test.ts
  # DE mirror of the UK suite - same deferred scope (real wallet-sheet
  # interaction) applies here too. Cross-border delivery is out of scope
  # for this project - only within-country (DE) delivery is exercised.
  # Pay on Account's localized name ("Zahlung auf Rechnung") is checked
  # absent from Express, not the English term.

  Scenario: VAT field is visible above the wallet buttons, and Pay on Account is not offered
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout now" button
    And I click on the "express checkout toggle" element
    Then the "express VAT number" should be displayed
    And the "express VAT number" should have attribute "placeholder" with value "DE123456789 oder ATU12345678"
    And the "express Google Pay" should be displayed
    And the "express checkout container" should not contain the text "Zahlung auf Rechnung"

  Scenario: An invalid VAT number is rejected, then a valid one is applied cleanly
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout now" button
    And I click on the "express checkout toggle" element
    And I fill in the "express VAT number" input field with "DE12"
    And I click on the "express VAT apply" button
    Then the "express validation message" should equal text "Die eingegebene USt-IdNr. ist ungültig. Bitte geben Sie eine Umsatzsteuer-Identifikationsnummer im Format DE123456789 ein"
    And the "express VAT number" should have class "is-invalid"

    When I fill in the "express VAT number" input field with "DE123456789"
    And I click on the "express VAT apply" button
    Then the "express VAT number" should not have class "is-invalid"
    And the "express VAT number" should equal the value "DE123456789"
