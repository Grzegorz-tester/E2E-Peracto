@smoke
@regression
Feature: Guest purchase journey

  # Full rewrite (2026-10-05). The previous version had hardcoded placeholder
  # credentials, an HIB-style "Cookie OK" step and a checkout flow that
  # doesn't exist here. Rebuilt and confirmed live end to end on staging the
  # same day (order 010629):
  # PDP -> DELIVERY -> basket -> /checkout/sign-in (guest email) ->
  # /checkout/delivery (Loqate address lookup, "Dove Delivery (Free)",
  # preferred date, required contact mobile) -> /checkout/billing (same as
  # delivery) -> /checkout/review-and-payment -> Opayo sandbox hosted pages
  # -> /checkout/thank-you.
  # - Delivery only works inside JT Dove's area: a Leeds address gets "you
  #   appear to be outside of our immediate delivery area" and no delivery
  #   option. NE46 4DQ (Hexham) is used here.
  # - Checkout totals are shown ex. VAT (£56.98); Opayo charges inc. VAT
  #   (£68.38).
  #
  # WARNING: places a REAL order on staging every run (Opayo sandbox card,
  # no money moves). Customer name "Velstar Test", Velstar-owned email.
  @places-real-order
  Scenario: Guest can buy a product for delivery and pay by card
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    Then I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Use this address" button
    Then the "current address postcode" should contain the text "NE46 4DQ"
    And the "outside delivery area message" should not be displayed
    When I click on the "Dove Delivery option" element
    And I fill in the "contact mobile" input field with "07700900000"
    And I fill in the "delivery notes" input field with "Velstar Test - automated test order, please ignore"
    And I click on the "Delivery Continue" button
    Then I should eventually be redirected to the "checkout-billing" page
    And I wait for the page to settle
    When I click on the "Same as delivery address" element
    And I click on the "Billing Continue" button
    Then I should eventually be redirected to the "checkout-review" page
    And I wait for the page to settle
    And the "review product name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    When I click on the "PROCEED TO PAYMENT" button
    And I pay with the "default" Opayo test card
    Then I should eventually be redirected to the "thank-you" page
    And the "thank you heading" should be displayed
    And the "order reference" should be displayed
    And the "order confirmation email" should contain the stored guest email
    And the "order line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "order delivery address" should contain the text "NE46 4DQ"
