@regression
Feature: Logged-in checkout - VAT number field (NL)

  # Migrated from P3Playwright watco/tests/basket-checkout/nl/logged-in-checkout-vat-field.test.ts
  # NL mirror of the UK suite - Pay on Account is VAT-gated here, and
  # this also holds for a logged-in account with a SAVED VAT number: Pay
  # on Account is visible immediately on page load, with no Apply click
  # needed, because the field arrives already-applied.

  Scenario: No saved VAT number - field is empty, Apply is disabled, and Pay on Account is hidden
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
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

    Then the "VAT number" should equal the value ""
    And the "VAT apply" should not be enabled
    And the "Pay on Account" should not be displayed

  Scenario: Has a saved VAT number - field is pre-populated, Pay on Account is visible on load, and both are editable
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

    Then the "VAT number" should equal the value "NL000099998B57"
    And the "VAT apply" should not be enabled
    And the "Pay on Account" should be displayed

    When I fill in the "VAT number" input field with "NL999999999B01"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT number" should equal the value "NL999999999B01"

  Scenario: Has a saved VAT number - clearing and applying persists a genuinely empty value and hides Pay on Account again
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

    # Explicitly (re-)apply a known VAT value regardless of the account's
    # current state, matching the source's self-healing intent against a
    # previous interrupted run leaving a different value behind.
    When I fill in the "VAT number" input field with "NL000099998B57"
    And I click on the "VAT apply" button
    Then the "VAT number" should equal the value "NL000099998B57"
    And the "Pay on Account" should be displayed

    When I fill in the "VAT number" input field with ""
    Then the "VAT apply" should be enabled
    When I click on the "VAT apply" button
    Then the "VAT number" should equal the value ""
    And the "VAT number" should not have class "is-invalid"
    And the "Pay on Account" should not be displayed
