@regression
Feature: Guest checkout - NIP and NIP-EU fields (PL)

  # Migrated from P3Playwright watco/tests/basket-checkout/pl/guest-checkout-vat-field.test.ts
  #
  # PL is the ONE market with genuinely TWO separate fields:
  # - NIP - domestic Polish tax ID. No tax effect by itself, no comment.
  # - NIP-EU - the EU VAT number (same input id every other market uses
  #   for its single VAT field). The ONLY field that zero-rates the
  #   order; has a comment.
  #
  # Pay on Account is not just hidden here - it's entirely ABSENT from
  # the DOM at every stage, regardless of VAT, unlike DE/NL/BE-NL/BE-FR's
  # CSS-based hide/reveal gating.

  Scenario: Both fields are visible, Pay on Account never appears, and only NIP-EU zero-rates the order
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I click on the "basket header link" element
    And I click on the "Checkout now" button
    And I click on the "guest checkout toggle" element
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "guest email submit" button
    Then I should be redirected to the "checkout-delivery" page

    When I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Telephone" input field with "500000000"
    And I click on the "Enter address manually" link
    And I fill in the "Address line 1" input field with "Testowa 1"
    And I fill in the "City" input field with "Warszawa"
    And I fill in the "Postcode" input field with "00-001"
    And I select the "Polska" option from the "Country" dropdown
    And I click on the "accordion continue" element
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    Then the "NIP number" should be displayed
    And the "NIP number" should have attribute "placeholder" with value "0123456789"
    And the "NIP number label" should be displayed
    And the "NIP number comment" should not be displayed

    Then the "VAT number" should have attribute "placeholder" with value "PL1234567890"
    And the "VAT number label" should be displayed
    And the "VAT number comment" should equal text "Jeśli jesteś podatnikiem VAT w UE, podaj numer z przedrostkiem PL — zastosujemy stawkę 0% dla transakcji wewnątrzwspólnotowych."

    Then the "NIP apply" should not be enabled
    And the "VAT apply" should not be enabled
    And the "VAT summary row" should contain the text "23%"
    And the "Pay on Account" should not be displayed

    When I fill in the "NIP number" input field with "9876543210"
    And I click on the "NIP apply" button
    Then the "NIP number" should not have class "is-invalid"
    And the "VAT summary row" should contain the text "23%"

    When I fill in the "VAT number" input field with "PL1234567890"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT summary row" should contain the text "0%"
    And the "Pay on Account" should not be displayed
    And the "payment on account minimum order notice" should not be displayed
