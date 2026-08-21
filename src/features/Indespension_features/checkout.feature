@regression
Feature: Checkout payment methods by customer type

  # Covers the manual test plan's "User Groups > Payment on checkout"
  # suite (Credit/Cash/Guest). Confirmed live (2026-08-21) what these
  # actually mean on this site:
  #
  # - Credit (trade account, pays on invoice terms): reaches "Pay on
  #   Account" with a mandatory PO Number, no card gateway involved at
  #   all. Covered end-to-end in logged-in-purchase-journey.feature
  #   instead of here, since it's the same account used by every other
  #   logged-in scenario in this project.
  # - Guest: reaches a real card payment step (GlobalPayments hosted
  #   fields). Covered below.
  # - Cash: NOT yet identified live. The storefront's account/checkout UI
  #   only ever showed two payment shapes - "Pay on Account" for the
  #   credit-terms test account, "Pay now" (card) for guest - no third,
  #   distinct "Cash" flow was found by exploring as either of those. This
  #   likely requires a second logged-in test account deliberately
  #   configured on a different (non-credit) customer/user group in
  #   INDESPENSION_ADMIN, which is bigger than this pass - flagged for a
  #   human decision rather than guessed at.
  #
  # Declined-card cases (Cash/Guest) are ALSO not covered: see the
  # "GlobalPayments test card" comment below - every card currently fails
  # identically before being evaluated, so there is no live way yet to
  # distinguish a declined card from a successful one.

  Background:
    Given I am on the "blueline-trailer-pdp" page
    # Confirmed live (2026-08-21): clicking "Add to Basket" immediately on
    # page load can silently no-op - this Next.js PDP's click handler
    # isn't always attached yet at the point Playwright considers the
    # button "visible and stable" (the same hydration-race shape as the
    # login form issue noted in logging-in.feature). Retrying once against
    # the real success signal, rather than a fixed sleep, is the existing
    # framework-wide pattern for this.
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears
    When I click on the "Go to Checkout" button
    Then I should be redirected to the "checkout" page

  # IMPORTANT: this scenario is expected to currently FAIL at the final
  # step. Confirmed live (2026-08-21): GlobalPayments' hosted card fields
  # work correctly (the card is filled, formatted, and validated
  # correctly - Visa is detected from the number, no client-side errors),
  # but submitting always returns a backend "Payment Error: no gateway
  # available" before the card itself is ever evaluated. This is a
  # staging environment/gateway-configuration gap, not a step-definition
  # or selector bug (see GLOBALPAYMENTS_TEST_CARDS in
  # payment-test-cards.ts) - kept in the suite so a real fix shows up as
  # this scenario turning green, rather than the gap staying invisible.
  Scenario: Guest can complete checkout with a card payment
    When I click on the "Guest checkout" element
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page

    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "SW1A 2AA"
    And I click on the "Use this address" button
    And I fill in the "Phone number" input field with "07377777777"
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    When I check the "same as delivery checkbox"
    And I click on the "Billing continue" button
    Then I should be redirected to the "checkout-review" page

    When I check the "delivery fee acknowledgement"
    And I click on the "Place order" button
    And I pay with the "default" GlobalPayments test card
    Then I should be redirected to the "checkout-thank-you" page
    And the "order reference" should be displayed
    And the "order confirmation email" should contain the stored guest email
