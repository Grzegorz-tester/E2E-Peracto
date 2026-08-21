@regression
Feature: Logged-in checkout - NIP and NIP-EU fields (PL)

  # Migrated from P3Playwright watco/tests/basket-checkout/pl/logged-in-checkout-vat-field.test.ts
  # "account test user with vat" has a saved NIP-EU (PL9876543210) but no
  # saved NIP - matching the source's own scenario coverage (it never
  # tests a saved NIP). Pay on Account never appears on PL regardless of
  # login/VAT state.

  Scenario: No saved NIP/NIP-EU - both fields are empty, standard rate applies, and Pay on Account is never offered
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

    Then the "NIP number" should equal the value ""
    And the "VAT number" should equal the value ""
    And the "NIP apply" should not be enabled
    And the "VAT apply" should not be enabled
    And the "Pay on Account" should not be displayed
    And the "VAT summary row" should contain the text "23%"

  Scenario: Has a saved NIP-EU - field is pre-populated and zero-rated on load, and both fields are independently editable
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

    Then the "VAT number" should equal the value "PL9876543210"
    And the "VAT apply" should not be enabled
    And the "NIP number" should equal the value ""
    And the "VAT summary row" should contain the text "0%"

    When I fill in the "VAT number" input field with "PL0987654321"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT number" should equal the value "PL0987654321"

    When I fill in the "NIP number" input field with "9876543210"
    And I click on the "NIP apply" button
    Then the "NIP number" should not have class "is-invalid"
    And the "NIP number" should equal the value "9876543210"
    And the "VAT summary row" should contain the text "0%"

  Scenario: Has a saved NIP-EU - clearing and applying persists a genuinely empty value and reverts to the standard rate
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

    # Explicitly (re-)apply a known NIP-EU value regardless of the
    # account's current state, matching the source's self-healing intent
    # against a previous interrupted run leaving a different value
    # behind.
    When I fill in the "VAT number" input field with "PL9876543210"
    And I click on the "VAT apply" button
    Then the "VAT number" should equal the value "PL9876543210"
    And the "VAT summary row" should contain the text "0%"

    When I fill in the "VAT number" input field with ""
    Then the "VAT apply" should be enabled
    When I click on the "VAT apply" button
    Then the "VAT number" should equal the value ""
    And the "VAT number" should not have class "is-invalid"
    And the "VAT summary row" should contain the text "23%"
