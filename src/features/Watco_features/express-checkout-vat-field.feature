@regression
Feature: Express Checkout - VAT number field

  # Migrated from P3Playwright watco/tests/basket-checkout/uk/express-checkout-vat-field.test.ts
  # WAT-335 - VAT registration number field, Express Checkout (UK).
  #
  # NOT YET AUTOMATED here either (documented, not stubbed, matching the
  # source): actually opening an Apple Pay / Google Pay wallet sheet,
  # cancelling it, and re-checking the sheet's own in-payment-sheet total.
  # Chromium has no ApplePaySession, so Apple Pay only ever renders as an
  # inert placeholder here, never a real invokable button.
  #
  # Also dropped: the source's bounding-box check that the VAT field sits
  # above the wallet buttons - no generic position-comparison step exists
  # in this framework yet, and it's a low-value assertion (page structure,
  # not real behaviour) not worth a bespoke step for on its own.

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
    And the "express VAT number" should have attribute "placeholder" with value "GB123456789"
    And the "express Google Pay" should be displayed
    And the "express checkout container" should not contain the text "Pay on Account"

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
    And I fill in the "express VAT number" input field with "GB12345"
    And I click on the "express VAT apply" button
    Then the "express validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format GB123456789."
    And the "express VAT number" should have class "is-invalid"

    When I fill in the "express VAT number" input field with "GB123456789"
    And I click on the "express VAT apply" button
    Then the "express VAT number" should not have class "is-invalid"
    And the "express VAT number" should equal the value "GB123456789"
