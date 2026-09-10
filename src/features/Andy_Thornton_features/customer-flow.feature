@regression
Feature: Guest product purchase flow

  # Guest checkout, not a logged-in purchase - the generic LOGGED_IN_EMAIL
  # isn't a valid Andy Thornton account (see logging-in.feature) and guest
  # checkout is the real, fully-working path on this storefront anyway
  # (confirmed live end-to-end 2026-09-05, including payment). Places a
  # real order on staging, which is fine per this repo's staging rules -
  # "Velstar Test" is used as the customer name per CLAUDE.md's convention
  # for checkout test data.
  Scenario: Successful guest checkout purchase
    Given I am on the "pdp" page
    When I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout" button
    Then I should be redirected to the "checkout" page

    When I click on the "Guest checkout radio" button
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    Then I should be redirected to the "checkout-delivery" page

    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I click on the "Manually enter your address" element
    And I fill in the "address line 1" input field with "221B Baker Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "NW1 6XE"
    And I click on the "Use this address" button
    Then the "current delivery address" should contain the text "221B Baker Street"

    When I fill in the "delivery phone" input field with "07700900000"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button
    Then I should be redirected to the "checkout-billing" page

    When I click on the "billing same as delivery" element
    And I click on the "Use this address" button
    Then I should be redirected to the "checkout-review" page

    When I click on the "Continue to Payment" button
    Then I should be redirected to the "opayo-card-selection" page

    When I click on the "Visa" element
    Then I should be redirected to the "opayo-card-details" page

    # Opayo/Elavon's own published sandbox test card - not project-specific,
    # so no dedicated payment-test-cards.ts entry (unlike the CyberSource/
    # Verifone/GlobalPayments cards there, which need a bespoke step to
    # reach into an iframe; this hosted redirect page needs no such step).
    When I fill in the "Card number" input field with "4929000000006"
    And I fill in the "Expiry month" input field with "12"
    And I fill in the "Expiry year" input field with "30"
    And I fill in the "CVC" input field with "123"
    And I click on the "Confirm card details" button
    Then I should be redirected to the "opayo-card-confirmation" page

    When I click on the "Pay now" button
    Then I should eventually be redirected to the "checkout-thank-you" page
    And the "order reference" should be displayed
    And the "order total" should equal text "£158.40"
