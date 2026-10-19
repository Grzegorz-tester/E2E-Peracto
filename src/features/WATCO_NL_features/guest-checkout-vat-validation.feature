@regression
Feature: Guest checkout - VAT number field validation (NL)

  # Migrated from P3Playwright watco/tests/basket-checkout/nl/guest-checkout-vat-validation.test.ts
  # NL mirror of the UK suite, but Pay on Account is VAT-gated here - the
  # first scenario applies a VALID VAT first (revealing Pay on Account),
  # then dirties the field again and uses Pay on Account as normal. The
  # second scenario (fresh session, no valid VAT ever applied) has no
  # Pay on Account to select - it uses "Pay by card" / the Adyen terms
  # checkbox instead, which is always offered.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout now" button
    And I click on the "guest checkout toggle" element
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "guest email submit" button
    Then I should be redirected to the "checkout-delivery" page
    When I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Telephone" input field with "0611111100"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "Teststraat 1"
    And I fill in the "City" input field with "Amsterdam"
    And I fill in the "Postcode" input field with "1011AA"
    And I select the "Nederland" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

  Scenario: An invalid VAT number is rejected, then a valid one is accepted and later dirtying it again blocks proceeding
    When I fill in the "VAT number" input field with "NL12"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "Het ingevoerde btw-nummer is ongeldig. Voer een btw-nummer in met het formaat NL000099998B57."
    And the "VAT number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "NL000099998B57"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "Pay on Account" should be displayed

    When I fill in the "VAT number" input field with "NL999999999B01"
    And I click on the "Pay on Account" element
    Then the "VAT form group" should have class "js-vat-apply-group--dirty"

    When I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "Dit veld bevat niet‑toegepaste wijzigingen. Pas deze toe of maak het veld leeg voordat je verdergaat"
    And the "Pay on Account terms" radio button should not be checked

  Scenario: An invalid, applied VAT number also blocks proceeding, via the card payment method since Pay on Account is never revealed
    When I fill in the "VAT number" input field with "NL12"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "Het ingevoerde btw-nummer is ongeldig. Voer een btw-nummer in met het formaat NL000099998B57."
    And the "VAT number" should have class "is-invalid"

    When I click on the "Pay by card" element
    And I click on the "Adyen terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "Dit veld bevat niet‑toegepaste wijzigingen. Pas deze toe of maak het veld leeg voordat je verdergaat"
    And the "Adyen terms" radio button should not be checked
