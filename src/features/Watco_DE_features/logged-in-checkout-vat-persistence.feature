@regression
@places-real-order
Feature: Logged-in checkout - VAT number persistence to account (DE)

  # Migrated from P3Playwright watco/tests/basket-checkout/de/logged-in-checkout-vat-persistence.test.ts
  # DE mirror of the UK suite. Pay on Account is VAT-gated here, but
  # since every step in this test always has a valid VAT number applied
  # (either the baseline or the edited value), Pay on Account is already
  # visible by the time it's needed - no extra handling required. This
  # delivery address is DOMESTIC (Berlin) - cross-border delivery is out
  # of scope for this project - so the VAT amount is expected to carry
  # through unchanged, not drop to zero. Places TWO real orders via Pay
  # on Account against the shared "account test user with vat" account
  # (DE123456789 baseline) - one with an edited VAT number, one
  # restoring the original. SIMPLIFIED from the source the same way the
  # UK file is - see that file's docblock for why.

  Scenario: An edited VAT number persists to the account after the order is placed
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user with vat" user's email
    And I fill in the "Password" input field with the "account test user with vat" user's password
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page

    When I am on the "basket" page
    And I clear the basket
    And I am on the "home" page
    And I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout now" button
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed
    And the "VAT number" should equal the value "DE123456789"

    When I fill in the "VAT number" input field with "DE999999999"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And I remember the text of "VAT summary amount" as "vat before order"

    When I click on the "Pay on Account" element
    And I check the "Pay on Account terms", retrying until it is checked
    Then the "Pay now" should be displayed
    When I click on the "Pay now" button
    Then I should be redirected to the "checkout-thanks" page
    And the "VAT summary amount" text should equal the remembered "vat before order"

    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "DE999999999"

    When I am on the "basket" page
    And I clear the basket
    And I am on the "home" page
    And I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout now" button
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "VAT number" should be displayed
    When I fill in the "VAT number" input field with "DE123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

    When I click on the "Pay on Account" element
    And I check the "Pay on Account terms", retrying until it is checked
    Then the "Pay now" should be displayed
    When I click on the "Pay now" button
    Then I should be redirected to the "checkout-thanks" page

    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "DE123456789"
