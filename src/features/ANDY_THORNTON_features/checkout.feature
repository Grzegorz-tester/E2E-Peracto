@regression
Feature: Checkout sign-in step

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): see
  # PDP.feature - an undismissed Cookiebot banner intercepts "Add to
  # basket" on a fresh consent-less context, leaving the basket empty
  # (so "Checkout" never appears). Also see PDP.feature's second note:
  # navigating to "basket" too fast after clicking can race the
  # add-to-basket request itself - "I wait for the page to settle" first.

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): clicking
  # "Checkout" doesn't redirect to /checkout instantly - a scenario that
  # acts immediately afterwards without waiting for it (e.g. clicking
  # "Guest checkout radio" straight away) can still be sitting on /basket,
  # where that element isn't mapped at all ("no selector resolved").
  # Confirming the redirect in Background, once, covers every scenario.
  Background:
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    When I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    And I click on the "Checkout" button
    Then I should be redirected to the "checkout" page

  Scenario: Verify checkout sign-in step elements
    Then the "checkout total" should be displayed
    And the "Existing customer radio" should be displayed
    And the "Guest checkout radio" should be displayed

  Scenario: Verify choosing Guest checkout reveals the guest email field
    When I click on the "Guest checkout radio" button
    Then the "Guest email" should be displayed


  # 2026-09-30: confirmed live - the guest delivery form keeps "Use this
  # address" disabled until first name, last name, address line 1, city and
  # postcode are all filled (no error text; the button state is the check).
  # Stops on the Delivery step, so no order is placed.
  Scenario: The guest delivery address can't be used until its required fields are filled
    When I click on the "Guest checkout radio" button
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    Then I should be redirected to the "checkout-delivery" page
    When I click on the "Manually enter your address" element
    Then the "Use this address" should not be enabled
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    Then the "Use this address" should not be enabled
    When I fill in the "address line 1" input field with "221B Baker Street"
    And I fill in the "address city" input field with "London"
    Then the "Use this address" should not be enabled
    When I fill in the "address postcode" input field with "NW1 6XE"
    Then the "Use this address" should be enabled
