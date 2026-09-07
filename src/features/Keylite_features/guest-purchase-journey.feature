@regression
Feature: Guest purchase journey

  # Confirmed live 2026-09-06, end to end through Review & Pay:
  # PDP quick-select -> basket -> checkout/sign-in (guest) -> delivery
  # address -> delivery method -> billing (same as delivery) -> review.
  #
  # CONFIRMED SITE QUIRKS:
  # - The delivery address form's submit ("Use this address")
  #   intermittently does nothing, with EITHER a JS-dispatched OR a forced
  #   click - reproduced with both. Tries the JS-dispatch variant first,
  #   then falls back to a plain "if present" (forced) click as a second
  #   attempt with a different click mechanic, since which one actually
  #   works has varied between runs.
  # - "Guest checkout" (a radio-select option) needs the JS-dispatch click
  #   variant - the generic (forced) click left the Guest email field never
  #   appearing, confirmed live, same class of issue as elsewhere in this
  #   suite (a real click lands on something else at that position).
  #
  # NOT YET COMPLETED: payment. This site uses a Braintree/PayPal Dropin
  # (Card/PayPal/Google Pay), not one of this repo's already-supported
  # gateways (CyberSource/Verifone/Adyen/GlobalPayments). The card sheet is
  # hidden until the ".braintree-option__card" toggle is clicked, and its
  # hosted iframe fields (credit-card-number, expiration) can then be
  # filled - confirmed live - but clicking "Confirm Payment" afterwards
  # neither errors nor advances to a thank-you page in this exploration,
  # and no CVV field ever appeared to fill. This needs dedicated follow-up
  # (a new Braintree-specific payment step, mirroring the existing
  # CyberSource/Verifone/Adyen/GlobalPayments steps in checkout.ts) before
  # a real order can be placed and asserted here - deliberately not
  # guessed at further. This scenario stops at a confirmed-correct Review &
  # Pay page instead of asserting an order that was never actually placed.

  Scenario: A guest can add a window to basket and reach Review & Pay with the right order details
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the page to settle

    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Checkout" element
    Then I should be redirected to the "checkout-sign-in" page

    When I click on the "1st" "Guest checkout" element via JavaScript
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page

    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address county" input field with "Greater London"
    And I fill in the "address postcode" input field with "SW1A 2AA"
    And I click on the "1st" "Use this address" element via JavaScript
    And I wait for the page to settle
    And I click on the "Use this address" element if present
    And I wait for the page to settle
    And I fill in the "Phone number" input field with "07911123456"
    And I click on the "1st" "delivery method option" element
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    When I wait for the page to settle
    And I click on the "1st" "same as delivery checkbox" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "Billing continue" element via JavaScript
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed
    And the "review product name" should contain the text "ray.lux"
    And the "review product price" should be displayed
    And the "review current address" should contain the text "SW1A 2AA"
