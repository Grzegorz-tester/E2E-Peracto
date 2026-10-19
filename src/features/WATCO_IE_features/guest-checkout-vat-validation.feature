@regression
Feature: Guest checkout - VAT number field validation (IE)

  # Migrated from P3Playwright watco/tests/basket-checkout/ie/guest-checkout-vat-validation.test.ts
  # IE mirror of the UK suite. Ireland has no XI-style secondary prefix
  # (that's UK/Northern-Ireland-specific), so this covers the IE length
  # boundary instead: IE9999999L is IE + 7 digits + 1 letter (8
  # alphanumeric characters) - VERIFIED live in the source (staging,
  # 2026-08-06), including that a LONGER value (7 digits + 2 letters) is
  # also accepted, not just the exact-8 boundary.

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
    And I fill in the "Telephone" input field with "0870000000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "1 Test Street"
    And I fill in the "City" input field with "Dublin"
    And I fill in the "Postcode" input field with "D01 F5P2"
    And I select the "Ireland" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

  Scenario: An invalid VAT number is rejected, a too-short number is rejected, and a longer-than-minimum number is accepted
    When I fill in the "VAT number" input field with "IE12"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format IE9999999L."
    And the "VAT number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "IE1234567"
    And I click on the "VAT apply" button
    Then the "VAT number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "IE1234567L"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

    When I fill in the "VAT number" input field with "IE1234567LW"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

  Scenario: Editing the field without Applying blocks proceeding with an unsaved-changes warning
    When I fill in the "VAT number" input field with "IE7654321W"
    And I click on the "Pay on Account" element
    Then the "VAT form group" should have class "js-vat-apply-group--dirty"

    When I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "There are unsaved updates to this field, please apply the changes or clear the field before proceeding."
    And the "Pay on Account terms" radio button should not be checked

  Scenario: An invalid, applied VAT number also blocks proceeding
    When I fill in the "VAT number" input field with "IE12"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format IE9999999L."
    And the "VAT number" should have class "is-invalid"

    When I click on the "Pay on Account" element
    And I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "There are unsaved updates to this field, please apply the changes or clear the field before proceeding."
    And the "Pay on Account terms" radio button should not be checked
