@smoke
@regression
Feature: Purchase Journey

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > Purchase
  # Journey" (cases 527-528). Confirmed real (test-mode) payments/orders on
  # KOOL staging are acceptable, same as Insinkerator_EU's guest/logged-in
  # purchase journeys.
  #
  # Both scenarios below are tagged @places-real-order: whenever a project's
  # env file sets UI_AUTOMATION_HOST=production (e.g. env/KOOL_PROD.env),
  # src/index.ts automatically appends "and not @places-real-order" to every
  # profile's tag filter, so these are skipped there regardless of which
  # profile (@smoke/@regression/etc.) is run - never placing a real order on
  # a live storefront. Tag any other project's order-completing scenario the
  # same way rather than relying on remembering to exclude it manually.

  # Verifone card payment is now CONFIRMED WORKING end-to-end (see "I pay
  # with the <card> Verifone test card" in checkout.ts) - the earlier
  # blocker was the test card, not a missing selector or step. Submitting
  # always goes through real 3D Secure via Cardinal Commerce; the source
  # suite's own documented numbers (4111111111111111 etc.) trigger an
  # actual 3DS challenge that never resolves in headless Chromium (looks
  # like fraud-detection/device-fingerprinting never completing for
  # automation). payment-test-cards.ts's visa/mastercard/amex entries use
  # Cardinal's own published "successful frictionless" numbers instead
  # (no challenge UI), confirmed live to complete the full redirect chain
  # (payment-transactions -> lookupThreeDS -> complete ->
  # /payment-return/checkout -> /checkout/thank-you) in ~15-20s.
  #
  # STILL NOT COMPLETE, for an unrelated reason: this needs a guest-specific
  # sign-in-or-continue-as-guest step at the start of checkout, which
  # wasn't reached - live attempts to add a product to the basket as a
  # guest were intermittently blocked (pricing/"Add to basket" not
  # rendering for a guest session, on multiple different products, across
  # separate attempts - see pdp.feature's note on this). The delivery/
  # billing/payment structure below is otherwise identical to the
  # logged-in journey and confirmed correct.
  @places-real-order
  Scenario: Guest user - Card payment - Complete purchase from cart to confirmation
    Given I am on the "hose-set-pdp" page
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    Then the "no items message" should not be displayed
    # TODO: guest sign-in/continue step here (not yet identified), then:
    When I click on the "CHECKOUT SECURELY" button
    Then I should be redirected to the "checkout" page
    When I click on the "Delivery" element
    And I fill in the "Telephone" input field with "07911123456"
    And I click on the "PROCEED" button
    Then the "delivery options" should be displayed
    When I click on the "first delivery option" element
    And I click on the "PROCEED" button
    When I click on the "billing address" element
    And I click on the "PROCEED" button
    When I click on the "PAY ON CARD" button
    And I pay with the "visa" Verifone test card
    Then I should be redirected to the "thank-you" page

  # Confirmed live end-to-end, including a real order reaching Thank You.
  # Checkout is one page (/checkout) with four accordion sections: Sign
  # In, Delivery, Billing, Review and Payment. PROCEED stays disabled
  # until Telephone is filled (Delivery) and until the saved address is
  # explicitly clicked (Billing) - both required, not just recommended.
  @places-real-order
  Scenario: Logged-in user - Payment on Account - Complete purchase successfully
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    Then the "no items message" should not be displayed

    When I click on the "CHECKOUT SECURELY" button
    Then I should be redirected to the "checkout" page

    When I click on the "Delivery" element
    And I fill in the "Telephone" input field with "07911123456"
    And I click on the "PROCEED" button
    Then the "delivery options" should be displayed
    When I click on the "first delivery option" element
    And I click on the "PROCEED" button

    When I click on the "billing address" element
    And I click on the "PROCEED" button

    When I click on the "PAY ON ACCOUNT" button
    Then I should be redirected to the "thank-you" page
