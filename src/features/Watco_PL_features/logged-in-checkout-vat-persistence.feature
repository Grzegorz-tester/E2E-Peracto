@regression
Feature: Logged-in checkout - NIP-EU persistence to account (PL)

  # Migrated from P3Playwright watco/tests/basket-checkout/pl/logged-in-checkout-vat-persistence.test.ts
  #
  # PL never offers Pay on Account, so this uses a REAL Adyen test-card
  # payment instead - the source confirms live (staging, 2026-08-06)
  # that staging's Adyen client config runs in test mode, so the
  # standard Adyen test card resolves with no 3-D Secure challenge. The
  # "I fill in the Adyen test card details" step (checkout.ts) is NEW
  # this session, built from the source's own already-verified selectors
  # rather than rediscovered from scratch - it has not yet been run live
  # against this framework's actual step timing/overlay quirks, unlike
  # every Pay-on-Account-based persistence file elsewhere. Confirm this
  # scenario live before trusting it, the same way every other newly
  # migrated flow in this project has been.
  #
  # NIP-EU is the field that drives VAT treatment - this test edits
  # NIP-EU, not NIP, matching every other market's single-VAT-field
  # persistence test; NIP itself is left untouched throughout. PL
  # zero-rates for ANY valid NIP-EU (domestic or not), so the carried-
  # through VAT amount here is zero. Places TWO real orders against the
  # shared "account test user with vat" account (PL9876543210 baseline)
  # - one with an edited NIP-EU, one restoring the original. SIMPLIFIED
  # from the source the same way the UK file is - see that file's
  # docblock for why.

  Scenario: An edited NIP-EU persists to the account after the order is placed
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
    And the "VAT number" should equal the value "PL9876543210"

    When I fill in the "VAT number" input field with "PL0123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And I remember the text of "VAT summary amount" as "vat before order"

    When I click on the "Pay by card" element
    And I check the "Adyen terms", retrying until it is checked
    And I fill in the Adyen test card details
    And I click on the "Adyen pay button" button
    Then I should be redirected to the "checkout-thanks" page
    And the "VAT summary amount" text should equal the remembered "vat before order"

    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "PL0123456789"

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
    When I fill in the "VAT number" input field with "PL9876543210"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

    When I click on the "Pay by card" element
    And I check the "Adyen terms", retrying until it is checked
    And I fill in the Adyen test card details
    And I click on the "Adyen pay button" button
    Then I should be redirected to the "checkout-thanks" page

    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "PL9876543210"
