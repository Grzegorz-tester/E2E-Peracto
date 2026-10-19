@regression
Feature: Guest checkout - VAT number field (FR)

  # Migrated from P3Playwright watco/tests/basket-checkout/fr/guest-checkout-vat-field.test.ts
  # FR mirror of the UK suite - also localizes its own URL PATHS (not
  # just VAT format/rate/currency): /panier, /valider-la-commande, France
  # as the delivery country. Unlike UK/IE, selecting Pay on Account shows
  # NO new-customer minimum-order notice.

  Scenario: VAT field is visible, Apply starts disabled, and Pay on Account has no minimum-order notice
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
    And I fill in the "Telephone" input field with "0600000000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "1 Rue de Test"
    And I fill in the "City" input field with "Paris"
    And I fill in the "Postcode" input field with "75001"
    And I select the "France" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

    Then the "VAT number" should have attribute "placeholder" with value "FRXX123456789"
    And the "VAT number label" should be displayed
    And the "VAT apply" should not be enabled
    And the "VAT number comment" should not be displayed

    When I remember the text of "VAT summary amount" as "vat before"
    And I remember the text of "order summary total" as "total before"
    And I fill in the "VAT number" input field with "FRAB123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT number" should equal the value "FRAB123456789"
    And the "VAT summary amount" text should equal the remembered "vat before"
    And the "order summary total" text should equal the remembered "total before"

    Then the "Pay by card" should be displayed
    And the "Pay on Account" should be displayed

    When I check the "Pay on Account"
    Then the "payment on account minimum order notice" should not be displayed
