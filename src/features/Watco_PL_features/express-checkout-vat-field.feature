@regression
Feature: Express Checkout - NIP and NIP-EU fields (PL)

  # Migrated from P3Playwright watco/tests/basket-checkout/pl/express-checkout-vat-field.test.ts
  # PL is the ONE market with genuinely TWO separate fields in Express
  # too - NIP (domestic tax ID, no tax effect) and NIP-EU (the EU VAT
  # number, reusing the platform-wide "VAT number" input id, the only
  # field that zero-rates the order). Pay on Account never appears here
  # at all, regardless of VAT.

  Scenario: Both fields are visible above the wallet buttons, and Pay on Account is never offered
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
    Then the "express NIP number" should be displayed
    And the "express NIP number" should have attribute "placeholder" with value "0123456789"
    And the "express VAT number" should be displayed
    And the "express VAT number" should have attribute "placeholder" with value "PL1234567890"
    And the "express Google Pay" should be displayed
    And the "Pay on Account" should not be displayed

  Scenario: An invalid NIP and an invalid NIP-EU are each rejected with their own format-specific error, then correctly-formatted values are applied cleanly
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
    And I fill in the "express NIP number" input field with "123"
    And I click on the "express NIP apply" button
    Then the "express NIP validation message" should equal text "Wprowadzony numer NIP jest nieprawidłowy. Wprowadź numer NIP w formacie 1234567890."
    And the "express NIP number" should have class "is-invalid"

    When I fill in the "express VAT number" input field with "PLX"
    And I click on the "express VAT apply" button
    Then the "express validation message" should equal text "Wprowadzony numer NIP jest nieprawidłowy. Wprowadź numer NIP w formacie PL1234567891."
    And the "express VAT number" should have class "is-invalid"

    When I fill in the "express NIP number" input field with "9876543210"
    And I click on the "express NIP apply" button
    Then the "express NIP number" should not have class "is-invalid"
    And the "express NIP number" should equal the value "9876543210"

    When I fill in the "express VAT number" input field with "PL1234567890"
    And I click on the "express VAT apply" button
    Then the "express VAT number" should not have class "is-invalid"
    And the "express VAT number" should equal the value "PL1234567890"
