@regression
Feature: Checkout field validation

  # IND-729 (Peracto API upgrade) case 312: required and malformed checkout
  # fields must be refused before anything is sent. Guest path only, so the
  # shared logged-in basket is untouched. Nothing here places an order.
  #
  # CONFIRMED 2026-11-13 (staging): the guest Continue and "Use this address"
  # buttons stay disabled until every required field has a value, and the
  # inputs use native validation (valueMissing / typeMismatch).
  # NOT asserted: an invalid postcode. "NOTAPOSTCODE" was accepted as a
  # delivery address on staging, 2026-11-13 - confirm the expected behaviour
  # before adding a check for it.

  Background:
    Given I am on the "blueline-trailer-pdp" page
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears
    When I click on the "Go to Checkout" button
    Then I should be redirected to the "checkout" page
    When I click on the "Guest checkout" element

  Scenario: Guest email is required and must be a valid address
    Then the "Guest email" input should be rejected as empty
    And the "Guest continue" should not be enabled
    When I fill in the "Guest email" input field with "not-an-email"
    Then the "Guest email" input should be rejected as invalid

  Scenario: The delivery address form refuses empty required fields
    When I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page
    And the "Use this address" should not be enabled
    And the "address first name" input should be rejected as empty
    And the "address last name" input should be rejected as empty
    And the "address line 1" input should be rejected as empty
    And the "address city" input should be rejected as empty
    And the "address postcode" input should be rejected as empty

  Scenario: A delivery phone number is required before choosing a delivery method
    When I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "SW1A 2AA"
    And I click on the "Use this address" button
    Then the "Phone number" should be displayed
    And the "Phone number" input should be rejected as empty
    And the "Delivery method continue" should not be enabled
