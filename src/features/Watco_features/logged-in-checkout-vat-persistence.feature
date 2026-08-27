@regression
@places-real-order
Feature: Logged-in checkout - VAT number persistence to account

  # Migrated from P3Playwright watco/tests/basket-checkout/uk/logged-in-checkout-vat-persistence.test.ts
  # WAT-305 - "any changes made during checkout are persisted back to the
  # customer account when the order is placed" (AC, Logged-In Customer
  # Behaviour).
  #
  # Places TWO real orders via Pay on Account against the shared "account
  # test user with vat" account (GB123456789 baseline): one with an edited
  # VAT number, one restoring the original - deliberately NOT via the
  # account profile page's own "Save details" form, which is a separate
  # confirmed bug (see account-profile-vat-save.feature) that silently
  # fails to persist at all.
  #
  # SIMPLIFIED from the source: the source self-heals by placing a WHOLE
  # EXTRA order first if the account isn't already at its documented
  # baseline (protecting against a previous interrupted run leaving it
  # elsewhere) - real, valuable defensive logic, but genuinely conditional
  # ("place an order" vs "don't") in a way Gherkin has no clean idiomatic
  # way to express without hiding a large, expensive branch inside one
  # opaque step. Dropped here in favour of asserting the account starts at
  # baseline directly - if a previous interrupted run left it dirty, this
  # now fails loudly instead of silently spending an extra order fixing
  # it. If that turns out to happen often in practice, worth reconsidering.

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
    And the "VAT number" should equal the value "GB123456789"

    When I fill in the "VAT number" input field with "GB999999999"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And I remember the text of "VAT summary amount" as "vat before order"

    When I click on the "Pay on Account" element
    And I check the "Pay on Account terms", retrying until it is checked
    Then the "Pay now" should be displayed
    When I click on the "Pay now" button
    Then I should be redirected to the "checkout-thanks" page
    # VERIFIED live in the source (staging, 2026-08-06): the thank-you page
    # shows the VAT AMOUNT but neither its RATE nor the customer's VAT
    # NUMBER anywhere on the page - nothing further to assert there.
    And the "VAT summary amount" text should equal the remembered "vat before order"

    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "GB999999999"

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
    When I fill in the "VAT number" input field with "GB123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"

    When I click on the "Pay on Account" element
    And I check the "Pay on Account terms", retrying until it is checked
    Then the "Pay now" should be displayed
    When I click on the "Pay now" button
    Then I should be redirected to the "checkout-thanks" page

    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "GB123456789"
