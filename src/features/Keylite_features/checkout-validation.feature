@regression
Feature: Checkout validation

  # CONFIRMED live 2026-09-23 - how Keylite's checkout rejects bad input
  # (none of these scenarios place an order):
  # - Guest email is a native type="email" field: an invalid or empty
  #   value is blocked by the browser's own validation, no custom message.
  # - The delivery address form shows no inline errors at all - "Use this
  #   address" simply stays disabled until every required field is filled.
  # - Phone is required natively (empty = browser validation), and a
  #   non-numeric value shows the site's own "Invalid phone number".
  # - "Same as delivery" on billing starts UNticked (a role="checkbox"
  #   button, not an <input>), so the default is a separate billing form.
  #
  # NOT covered, deliberately: postcode format. "NOTAPOSTCODE" is accepted
  # as a UK delivery postcode and carried straight through to the next
  # step (confirmed live) - that's a question for Keylite (is it meant to
  # be validated?), not something to assert either way here yet.
  # Only one delivery method exists on staging ("GB shipping service:
  # FREE"), so there's no non-default method to choose.

  Background:
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Checkout" element
    Then I should be redirected to the "checkout-sign-in" page
    When I click on the "1st" "Guest checkout" element via JavaScript

  Scenario: An invalid guest email is rejected and checkout does not advance
    When I fill in the "Guest email" input field with "not-an-email"
    And I click on the "1st" "Guest continue" element via JavaScript
    Then the "Guest email" input should be rejected as invalid
    And I should be redirected to the "checkout-sign-in" page

  Scenario: An empty guest email is rejected and checkout does not advance
    When I click on the "1st" "Guest continue" element via JavaScript
    Then the "Guest email" input should be rejected as empty
    And I should be redirected to the "checkout-sign-in" page

  Scenario: The delivery address can't be submitted until every required field is filled
    When I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page
    When I wait for the page to settle
    Then the "Use this address" should not be enabled
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address county" input field with "Greater London"
    Then the "Use this address" should not be enabled
    When I fill in the "address postcode" input field with "SW1A 2AA"
    Then the "Use this address" should be enabled

  Scenario: A missing or invalid phone number blocks the delivery step, and billing "same as delivery" reaches Review & Pay
    When I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page
    When I wait for the page to settle
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address county" input field with "Greater London"
    And I fill in the "address postcode" input field with "SW1A 2AA"
    And I click on the "1st" "Use this address" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "delivery method option" element
    And I click on the "1st" "Delivery method continue" element via JavaScript
    Then the "Phone number" input should be rejected as empty
    And I should be redirected to the "checkout-delivery" page

    When I fill in the "Phone number" input field with "abc"
    And I click on the "1st" "Delivery method continue" element via JavaScript
    Then the "delivery form" should contain the text "Invalid phone number"
    And I should be redirected to the "checkout-delivery" page

    When I fill in the "Phone number" input field with "07911123456"
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page
    When I wait for the page to settle
    And I click on the "1st" "same as delivery checkbox" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "Billing continue" element via JavaScript
    Then I should be redirected to the "checkout-review" page
    And the "review current address" should contain the text "SW1A 2AA"
