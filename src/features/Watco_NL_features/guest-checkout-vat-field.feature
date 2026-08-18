@regression
Feature: Guest checkout - VAT number field (NL)

  # Migrated from P3Playwright watco/tests/basket-checkout/nl/guest-checkout-vat-field.test.ts
  # NL behaves like DE (Pay on Account hidden until VAT applied, a real
  # business-customer comment), but its zero-rating rule is SIMPLER than
  # DE's delivery-country-aware one - applying a valid NL VAT number
  # zero-rates the order even for a domestic NL to NL delivery. No
  # separate cross-border test is needed here as a result.

  Scenario: VAT field is visible with the business-customer comment, applying a valid VAT number zero-rates the order and reveals Pay on Account
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
    And I fill in the "Telephone" input field with "0611111100"
    And I click on the "Enter address manually" link
    And I fill in the "Address line 1" input field with "Teststraat 1"
    And I fill in the "City" input field with "Amsterdam"
    And I fill in the "Postcode" input field with "1011AA"
    And I select the "Nederland" option from the "Country" dropdown
    And I click on the "accordion continue" element
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    Then the "VAT number" should have attribute "placeholder" with value "NL000099998B57"
    And the "VAT number label" should be displayed
    And the "VAT number comment" should equal text "Als u ons een btw-nummer verstrekt, zullen wij voor intracommunautaire transacties een btw-tarief van 0% hanteren"
    And the "Pay on Account" should not be displayed
    And the "VAT summary row" should contain the text "21%"

    When I fill in the "VAT number" input field with "NL000099998B57"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "Pay on Account" should be displayed
    And the "VAT summary row" should contain the text "0%"

    When I check the "Pay on Account"
    Then the "payment on account minimum order notice" should not be displayed
