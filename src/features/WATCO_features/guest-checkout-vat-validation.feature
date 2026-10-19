@regression
Feature: Guest checkout - VAT number field validation

  # Migrated from P3Playwright watco/tests/basket-checkout/uk/guest-checkout-vat-validation.test.ts
  # WAT-335 - VAT registration number field validation, guest checkout (UK).

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
    And I fill in the "Telephone" input field with "07700900000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "1 Test Street"
    And I fill in the "City" input field with "London"
    And I fill in the "Postcode" input field with "SW1A 1AA"
    And I select the "United Kingdom" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

  Scenario: An invalid VAT number is rejected, a too-long GB number is rejected, and an XI-prefixed number is accepted
    When I fill in the "VAT number" input field with "GB12345"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format GB123456789."
    And the "VAT number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "GB1234567890123"
    And I click on the "VAT apply" button
    Then the "VAT number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "XI123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

  # Editing without Applying leaves the field "dirty" and blocks proceeding
  # with an unsaved-changes warning, surfaced via the same error element
  # and generic message the invalid-format case above uses.
  Scenario: Editing the field without Applying blocks proceeding with an unsaved-changes warning
    When I fill in the "VAT number" input field with "GB987654321"
    # Clicking elsewhere blurs the VAT field, which is what actually marks
    # it dirty - the source explicitly calls .blur() for this same reason.
    And I click on the "Pay on Account" element
    Then the "VAT form group" should have class "js-vat-apply-group--dirty"

    When I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "There are unsaved updates to this field, please apply the changes or clear the field before proceeding."
    And the "Pay on Account terms" radio button should not be checked

  # AC: "the customer cannot proceed past the payment step until the error
  # is resolved or the field is cleared" - the scenario above only covers
  # an unapplied EDIT blocking proceeding; this covers an invalid value
  # that WAS Applied and is still showing is-invalid. Kept as its own
  # scenario (fresh Background setup) rather than a further step on top of
  # the scenario above - the source found appending it there flaky (the
  # error element sometimes never rendered) while a clean session
  # reproduced it reliably.
  Scenario: An invalid, applied VAT number also blocks proceeding
    When I fill in the "VAT number" input field with "GB12345"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "The entered VAT number is invalid. Enter a VAT number in the format GB123456789."
    And the "VAT number" should have class "is-invalid"

    When I click on the "Pay on Account" element
    And I click on the "Pay on Account terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "There are unsaved updates to this field, please apply the changes or clear the field before proceeding."
    And the "Pay on Account terms" radio button should not be checked
