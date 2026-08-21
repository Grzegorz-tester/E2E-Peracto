@regression
Feature: Express Checkout - VAT number field (BE-NL)

  # Migrated from P3Playwright watco/tests/basket-checkout/benl/express-checkout-vat-field.test.ts
  # BE-NL mirror of the UK suite - same deferred scope (real wallet-sheet
  # interaction) applies here too. Pay on Account's localized name
  # ("Betaling op facturatie") is checked absent from Express, not the
  # English term.

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
    And the "express VAT number" should have attribute "placeholder" with value "BE1234567890"
    And the "express Google Pay" should be displayed
    And the "express checkout container" should not contain the text "Betaling op facturatie"

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
    And I fill in the "express VAT number" input field with "BE12"
    And I click on the "express VAT apply" button
    Then the "express validation message" should equal text "Het ingevoerde btw-nummer is ongeldig. Voer een btw-nummer in met het formaat BE1234567890."
    And the "express VAT number" should have class "is-invalid"

    When I fill in the "express VAT number" input field with "BE0123456749"
    And I click on the "express VAT apply" button
    Then the "express VAT number" should not have class "is-invalid"
    And the "express VAT number" should equal the value "BE0123456749"
