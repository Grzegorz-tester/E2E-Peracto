@regression
Feature: Guest checkout - VAT number field (BE-FR)

  # Migrated from P3Playwright watco/tests/basket-checkout/befr/guest-checkout-vat-field.test.ts
  #
  # IMPORTANT DIVERGENCE FROM ITS OWN LANGUAGE SIBLING: BE-FR shares FR's
  # URL paths (/panier, /valider-la-commande) but NOT FR's VAT behaviour -
  # a live check on staging-fr confirmed FR always shows Pay on Account
  # regardless of VAT, whereas BE-FR hides it until a valid VAT number is
  # applied (matching DE/NL/BE-NL instead), with no explanatory comment
  # below the field (FR/UK/IE style) - a combination not seen on any
  # other market. Don't assume language implies behaviour; route implies
  # even less.
  #
  # Also note (source docblock): the QA doc's claim that BE-FR shows a
  # NIP/NIP-EU field pair (PL-only elsewhere) does not match live reality
  # - confirmed via DOM inspection there is exactly one VAT input here,
  # same id used platform-wide. Treated as a QA-doc copy-paste artifact,
  # not acted on.

  Scenario: VAT field is visible with no comment text, Pay on Account is hidden until a valid VAT number zero-rates the order
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
    And I fill in the "Telephone" input field with "0470000000"
    And I click on the "Enter address manually" link
    And I fill in the "Address line 1" input field with "Rue de Test 1"
    And I fill in the "City" input field with "Bruxelles"
    And I fill in the "Postcode" input field with "1000"
    And I select the "Belgique" option from the "Country" dropdown
    And I click on the "accordion continue" element
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    Then the "VAT number" should have attribute "placeholder" with value "BE1234567890"
    And the "VAT number label" should be displayed
    And the "VAT apply" should not be enabled
    And the "VAT number comment" should not be displayed
    And the "Pay on Account" should not be displayed
    And the "VAT summary row" should contain the text "21%"

    When I fill in the "VAT number" input field with "BE0411905847"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "Pay on Account" should be displayed
    And the "VAT summary row" should contain the text "0%"

    When I check the "Pay on Account"
    Then the "payment on account minimum order notice" should not be displayed
