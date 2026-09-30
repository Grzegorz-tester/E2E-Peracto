@regression
Feature: Logged-in purchase journey

  # CONFIRMED live 2026-09-06: differs from guest-purchase-journey.feature
  # at the sign-in step, not the address step as first thought - a
  # logged-in checkout still lands on "/checkout/sign-in" (same route as
  # guest), but its content is just a "you are currently logged in as
  # <email>" confirmation with a single "Continue" button, no guest/
  # existing-customer choice. From there it reaches "/checkout/delivery"
  # showing this account's real saved addresses (checkout-select-address)
  # to pick from, rather than the guest address-entry form.
  #
  # RETRACTED 2026-09-23 - an earlier "CONFIRMED SITE BUG" note here said
  # "checkout-select-address__continue-button" never advances past
  # "/checkout/delivery" for a logged-in customer. Re-verified live: it DOES
  # work - the URL just doesn't change. Delivery is one route with two
  # sections: after the address Continue, the saved-address list is
  # replaced IN PLACE by a required Phone field
  # (delivery-content__form-telephone), the delivery method radios
  # (delivery-content__radio-select) and a second continue button
  # (delivery-content__form-continue-button) - the same section the guest
  # journey already fills in. The old scenario simply never filled it, so
  # waiting for "/checkout/billing" timed out. "delivery method option" is
  # scoped to delivery-content__radio-select because the saved-address
  # radios use the same radio-select_option- testid prefix.
  #
  # Payment: same Braintree flow as guest-purchase-journey.feature (see
  # that file's comment). Places a REAL staging order, then checks the
  # order number from the thank-you page shows up in this account's own
  # order history.

  @places-real-order
  Scenario: A logged-in user can buy a window by card and finds the order in their account
    Given I require staging for this scenario
    And I am navigating the page as a "logged in" user
    # This account's basket is server-side and persists between runs (and
    # manual/probe sessions) - start from an empty one so the order holds
    # exactly what this scenario adds.
    And I am on the "basket" page
    And I wait for the page to settle
    And I clear the basket
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

    When I click on the "Signed-in continue" button
    Then I should be redirected to the "checkout-delivery" page

    When I click on the "1st" "saved address" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "saved address continue" element via JavaScript
    And I wait for the page to settle
    And I click on the "saved address continue" button if present
    And I wait for the page to settle
    And I fill in the "Phone number" input field with "07911123456"
    And I fill in the "delivery notes" input field with "Velstar Test - automated QA order, please ignore"
    And I click on the "1st" "delivery method option" element
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    # Unlike the guest journey, logged-in billing has no "same as delivery"
    # checkbox or billing continue button - it reuses the same saved-address
    # picker as delivery (checkout-select-address__*), confirmed live
    # 2026-09-23.
    When I wait for the page to settle
    And I click on the "1st" "saved address" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "saved address continue" element via JavaScript
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed
    And the "review product name" should contain the text "ray.lux"
    And the "review product price" should be displayed

    When I click on the "1st" "Pay now" element via JavaScript
    And I pay with the "Visa 3DS frictionless" Braintree test card
    Then I should eventually be redirected to the "checkout-thank-you" page
    And the "thank you content" should contain the text "Thank you for your order"
    And the "order product name" should contain the text "ray.lux"
    When I remember the text of "order reference" with the prefix "Order No." stripped, as "order number"
    And I am on the "account-orders" page
    Then the "orders table" should contain the remembered "order number"
