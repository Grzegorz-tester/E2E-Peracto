@regression
Feature: Guest purchase journey

  # Confirmed live 2026-09-06, end to end through Review & Pay:
  # PDP quick-select -> basket -> checkout/sign-in (guest) -> delivery
  # address -> delivery method -> billing (same as delivery) -> review.
  #
  # CONFIRMED SITE QUIRKS:
  # - The delivery address form's submit ("Use this address") used to
  #   look intermittently dead, worked around with a second "if present"
  #   click. Real cause (confirmed live 2026-09-23): the form resets itself
  #   ~500ms after first render, wiping fields filled too early and leaving
  #   the button disabled. With the settle step before filling (below), a
  #   single JS-dispatched click is reliable, so the fallback was removed.
  # - "Guest checkout" (a radio-select option) needs the JS-dispatch click
  #   variant - the generic (forced) click left the Guest email field never
  #   appearing, confirmed live, same class of issue as elsewhere in this
  #   suite (a real click lands on something else at that position).
  #
  # PAYMENT (CONFIRMED live 2026-09-23, order W000541): "Pay now" on
  # Review & Pay reveals a Braintree Drop-in (Card/PayPal/Google Pay,
  # sandbox) - see "I pay with the ... Braintree test card" in checkout.ts.
  # An earlier note here said "Confirm Payment neither errors nor
  # advances": that was a 3-D Secure challenge iframe silently waiting for
  # input after the plain 4111... Visa. The frictionless 3DS test card goes
  # straight through to /checkout/thank-you. Places a REAL staging order,
  # hence @places-real-order + the staging guard as the first step.

  @places-real-order
  Scenario: A guest can buy a window by card and sees the order confirmation
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the basket update to complete

    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Checkout" element
    Then I should be redirected to the "checkout-sign-in" page

    When I click on the "1st" "Guest checkout" element via JavaScript
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page

    # CONFIRMED live 2026-09-23: the delivery address form resets itself
    # ~500ms after "/checkout/delivery" first renders, wiping every field
    # filled before that point (the failing run lost Line 1 and City and
    # kept County/Postcode, depending on where the reset landed mid-fill),
    # leaving "Use this address" disabled. Settling first keeps every value.
    When I wait for the page to settle
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address county" input field with "Greater London"
    And I fill in the "address postcode" input field with "SW1A 2AA"
    And I click on the "1st" "Use this address" element via JavaScript
    And I wait for the page to settle
    And I fill in the "Phone number" input field with "07911123456"
    And I fill in the "delivery notes" input field with "Velstar Test - automated QA order, please ignore"
    And I click on the "1st" "delivery method option" element
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    # A separate billing address (not "same as delivery") - the only place
    # a billing address is ever shown back is the thank-you page, so it's
    # asserted there rather than on Review & Pay (which shows delivery
    # only). "Same as delivery" is covered in checkout-validation.feature.
    When I wait for the page to settle
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "1 Test Billing Road"
    And I fill in the "address city" input field with "Manchester"
    And I fill in the "address county" input field with "Greater Manchester"
    And I fill in the "address postcode" input field with "M1 1AE"
    And I click on the "1st" "Use this address" element via JavaScript
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed
    And the "review product name" should contain the text "ray.lux"
    And the "review product price" should be displayed
    And the "review current address" should contain the text "SW1A 2AA"

    When I click on the "1st" "Pay now" element via JavaScript
    And I pay with the "Visa 3DS frictionless" Braintree test card
    Then I should eventually be redirected to the "checkout-thank-you" page
    And the "thank you content" should contain the text "Thank you for your order"
    And the "order email" should contain the stored guest email
    And the "order delivery address" should contain the text "Velstar Test"
    And the "order delivery address" should contain the text "SW1A 2AA"
    And the "order product name" should contain the text "ray.lux"
    And the "order payment details" should contain the text "M1 1AE"
