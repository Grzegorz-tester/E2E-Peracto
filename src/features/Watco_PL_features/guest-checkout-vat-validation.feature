@regression
Feature: Guest checkout - NIP and NIP-EU field validation (PL)

  # Migrated from P3Playwright watco/tests/basket-checkout/pl/guest-checkout-vat-validation.test.ts
  #
  # VERIFIED live in the source (staging, 2026-08-06): a QA-doc-flagged
  # bug around the invalid-NIP error copy has since been fixed, but not
  # quite as the doc predicted - the doc's expected text (with a "PL"
  # prefix in the format example) is actually what NIP-EU's own error
  # now shows, while NIP's OWN error is a different, correct string with
  # no "PL" prefix (NIP itself never takes one). Both are asserted below
  # as currently-passing behaviour.
  #
  # PL never offers Pay on Account, so "unsaved edit"/"invalid applied"
  # blocking is demonstrated via the card/Adyen method instead, and the
  # invalid-applied scenario tests NIP (not NIP-EU/VAT) specifically,
  # matching the source's own coverage.

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
    And I fill in the "Telephone" input field with "500000000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "Testowa 1"
    And I fill in the "City" input field with "Warszawa"
    And I fill in the "Postcode" input field with "00-001"
    And I select the "Polska" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed

  Scenario: An invalid NIP and an invalid NIP-EU are each rejected with their own format-specific error, then editing NIP-EU without Applying blocks proceeding
    When I fill in the "NIP number" input field with "123"
    And I click on the "NIP apply" button
    Then the "NIP validation message" should equal text "Wprowadzony numer NIP jest nieprawidłowy. Wprowadź numer NIP w formacie 1234567890."
    And the "NIP number" should have class "is-invalid"

    When I fill in the "VAT number" input field with "PLX"
    And I click on the "VAT apply" button
    Then the "validation message" should equal text "Wprowadzony numer NIP jest nieprawidłowy. Wprowadź numer NIP w formacie PL1234567891."
    And the "VAT number" should have class "is-invalid"

    When I fill in the "NIP number" input field with "9876543210"
    And I click on the "NIP apply" button
    Then the "NIP number" should not have class "is-invalid"

    When I fill in the "VAT number" input field with "PL1234567890"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

    When I fill in the "VAT number" input field with "PL0987654321"
    And I click on the "Pay by card" element
    And I click on the "Adyen terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "validation message" should equal text "W tym polu znajdują się niezapisane zmiany. Zastosuj zmiany lub wyczyść pole przed kontynuowaniem"
    And the "Adyen terms" radio button should not be checked

  Scenario: An invalid, applied NIP also blocks proceeding via the card payment method
    When I fill in the "NIP number" input field with "123"
    And I click on the "NIP apply" button
    Then the "NIP validation message" should equal text "Wprowadzony numer NIP jest nieprawidłowy. Wprowadź numer NIP w formacie 1234567890."
    And the "NIP number" should have class "is-invalid"

    When I click on the "Pay by card" element
    And I click on the "Adyen terms" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "NIP validation message" should equal text "W tym polu znajdują się niezapisane zmiany. Zastosuj zmiany lub wyczyść pole przed kontynuowaniem"
    And the "Adyen terms" radio button should not be checked
