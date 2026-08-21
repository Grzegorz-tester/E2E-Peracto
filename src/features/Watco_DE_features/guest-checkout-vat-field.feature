@regression
Feature: Guest checkout - VAT number field (DE)

  # Migrated from P3Playwright watco/tests/basket-checkout/de/guest-checkout-vat-field.test.ts
  # DE mirrors IE/FR structurally (own localized paths: /warenkorb,
  # /kasse) but diverges behaviourally: Pay on Account is HIDDEN until a
  # valid VAT number is applied (UK/IE/FR always show it), and the VAT
  # field has a real business-customer comment. Cross-border delivery
  # (e.g. a DE VAT number zero-rating a delivery to Austria) is out of
  # scope here - only within-country (DE to DE) delivery is tested.

  Scenario: VAT field is visible with the business-customer comment, Pay on Account is hidden until a valid VAT number is applied
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
    And I fill in the "Telephone" input field with "017000000000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "Teststrasse 1"
    And I fill in the "City" input field with "Berlin"
    And I fill in the "Postcode" input field with "10115"
    And I select the "Deutschland" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

    Then the "VAT number" should have attribute "placeholder" with value "DE123456789 oder ATU12345678"
    And the "VAT number label" should be displayed
    And the "VAT number comment" should equal text "Durch die Angabe der USt-IdNr. weisen Sie sich bei uns als Geschäftskunde aus. Beispiel: DE123456789"
    And the "Pay on Account" should not be displayed

    When I remember the text of "VAT summary amount" as "vat before"
    And I fill in the "VAT number" input field with "DE123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT number" should equal the value "DE123456789"
    And the "VAT summary amount" text should equal the remembered "vat before"
    And the "Pay on Account" should be displayed

    # AC: new-customer minimum-order notice is "UK and IE only" - no such
    # message renders on DE regardless of order value.
    When I check the "Pay on Account"
    Then the "payment on account minimum order notice" should not be displayed
