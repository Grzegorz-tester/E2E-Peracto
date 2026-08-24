@smoke
@MIPA_regression
Feature: Payment on Account purchase flow

  # Full rewrite. This scenario was HIB contamination end to end - clicking
  # a "Portal" icon that isn't mapped to anything here, expecting a
  # "solas" page (an HIB product) that doesn't exist in pages.json, and
  # navigating a "place-order" page id that has never existed either (see
  # basket.feature's own note on that same bug). Rebuilt against the real
  # MIPA flow, confirmed live end to end including a real placed order:
  # PDP -> Add to basket -> Checkout modal -> Delivery -> Billing ->
  # Review & Pay -> Thank You. This account is set up as a trade/credit
  # customer, so checkout reaches a "Pay on Account" step requiring a
  # mandatory Purchase Order reference, with no card gateway involved at
  # all - this covers the "Payment on Account" smoke test.
  #
  # WARNING: this scenario places a REAL order on staging every time it
  # runs (Pay on Account, no money actually moves - it's an invoice-style
  # payment). Fine per this repo's staging rules, but don't re-run
  # needlessly.
  Scenario: Logged-in user can complete a Payment on Account purchase
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    And I wait for the basket to load
    When I click on the "Checkout" button
    Then I should be redirected to the "checkout" page
    When I click on the "Delivery method" element
    And I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    And I click on the "Courier delivery option" element
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    When I fill in the "PO Number" input field with "Velstar Test"
    And I click on the "Terms and conditions checkbox" element
    And I click on the "PLACE ORDER" button
    Then I should be redirected to the "thank-you" page
    And the "basket header title" should contain the text "Thank you for your order"
    And the "order reference" should be displayed
    And the "order confirmation email" should contain the "logged in" user's email
    And the "order total price" should contain the text "25.58"
