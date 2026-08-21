@regression
Feature: Guest checkout - VAT number field validation (BE-FR)

  # Migrated from P3Playwright watco/tests/basket-checkout/befr/guest-checkout-vat-validation.test.ts
  #
  # CORRECTION (live-verified this session): Pay on Account is always
  # available on BE-FR, not VAT-gated as an earlier note claimed - see
  # guest-checkout-vat-field.feature's own docblock for the live evidence.
  # This mirrors FR's un-gated structure as a result: Pay on Account is
  # used directly to blur/dirty the field in both scenarios below, with
  # no need to apply a valid VAT first.

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
    And I fill in the "Telephone" input field with "0470000000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "Rue de Test 1"
    And I fill in the "City" input field with "Bruxelles"
    And I fill in the "Postcode" input field with "1000"
    And I select the "Belgique" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

  Scenario: An invalid VAT number is rejected with an error message and a red field
    When I fill in the "VAT number" input field with "BE12"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "Le numéro de TVA entré n’est pas valable. Veuillez entrer un numéro de TVA au format: BE1234567890."
    And the "VAT number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "BE0411905847"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

  Scenario: Editing the field without Applying blocks proceeding with an unsaved-changes warning
    When I fill in the "VAT number" input field with "BE0987654321"
    And I click on the "Pay on Account" element
    Then the "VAT form group" should have class "js-vat-apply-group--dirty"

    When I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "Des modifications ne sont pas enregistrées. Veuillez valider ou vider le champ avant de continuer"
    And the "Pay on Account terms" radio button should not be checked

  Scenario: An invalid, applied VAT number also blocks proceeding
    When I fill in the "VAT number" input field with "BE12"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "Le numéro de TVA entré n’est pas valable. Veuillez entrer un numéro de TVA au format: BE1234567890."
    And the "VAT number" should have class "is-invalid"

    When I click on the "Pay on Account" element
    And I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "Des modifications ne sont pas enregistrées. Veuillez valider ou vider le champ avant de continuer"
    And the "Pay on Account terms" radio button should not be checked
