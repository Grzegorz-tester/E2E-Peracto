@regression
Feature: Logged-in checkout - VAT number field

  # Migrated from P3Playwright watco/tests/basket-checkout/uk/logged-in-checkout-vat-field.test.ts
  # WAT-335 - VAT registration number field, logged-in checkout (UK).
  #
  # "account test user with vat" is a SHARED account mutated by every run
  # (its basket and saved address persist across runs, unlike the guest
  # scenarios' always-fresh email) - the third scenario explicitly
  # re-applies a known VAT value itself before clearing it, rather than
  # assuming the scenario before it left a particular value behind.
  #
  # A logged-in account with a saved address skips the manual delivery
  # form entirely (see WatcoCheckoutPage.chooseDeliveryAddress in the
  # source) - straight to the shipping-option accordion instead.

  Scenario: No saved VAT number - field is empty, Apply is disabled, and Pay on Account is offered
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

    When I am on the "home" page
    And I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I click on the "basket header link" element
    And I click on the "Checkout now" button
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    Then the "VAT number" should equal the value ""
    And the "VAT apply" should not be enabled
    And the "Pay on Account" should be displayed

  Scenario: Has a saved VAT number - field is pre-populated and editable
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "account test user with vat" user's email
    And I fill in the "Password" input field with the "account test user with vat" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

    When I am on the "home" page
    And I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I click on the "basket header link" element
    And I click on the "Checkout now" button
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    Then the "VAT number" should equal the value "GB123456789"
    And the "VAT apply" should not be enabled

    When I fill in the "VAT number" input field with "GB987654321"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT number" should equal the value "GB987654321"

  Scenario: Has a saved VAT number - clearing and applying persists a genuinely empty value
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "account test user with vat" user's email
    And I fill in the "Password" input field with the "account test user with vat" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

    When I am on the "home" page
    And I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I click on the "basket header link" element
    And I click on the "Checkout now" button
    Then the "first shipping option" should be displayed
    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    # Explicitly (re-)apply a known VAT value regardless of the account's
    # current state, matching the source's self-healing intent against a
    # previous interrupted run leaving a different value behind.
    When I fill in the "VAT number" input field with "GB123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should equal the value "GB123456789"

    When I fill in the "VAT number" input field with ""
    Then the "VAT apply" should be enabled
    When I click on the "VAT apply" button
    Then the "VAT number" should equal the value ""
    And the "VAT number" should not have class "is-invalid"
