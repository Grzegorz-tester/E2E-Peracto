@regression
Feature: Guest product purchase flow

  # Guest checkout, not a logged-in purchase - the generic LOGGED_IN_EMAIL
  # isn't a valid Andy Thornton account (see logging-in.feature) and guest
  # checkout is the real, fully-working path on this storefront anyway
  # (confirmed live end-to-end 2026-09-05, including payment). Places a
  # real order on staging, which is fine per this repo's staging rules -
  # "Velstar Test" is used as the customer name per CLAUDE.md's convention
  # for checkout test data.
  #
  # FLAGGED (2026-09-14): was missing @places-real-order until now - since
  # Andy_Thornton_PROD.env was added pointing at the same FEATURE_PATH,
  # this scenario would otherwise have run a real payment attempt against
  # the live production site the moment the unrelated Cookiebot-banner
  # failure below got fixed (it had been failing at "Add to basket"
  # first, which accidentally masked this gap). Tagged now so
  # src/index.ts's productionExclusion strips it whenever
  # UI_AUTOMATION_HOST=production, same as every other order-placing
  # scenario in this repo.
  #
  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): see
  # PDP.feature - an undismissed Cookiebot banner intercepts "Add to
  # basket" on a fresh consent-less context, leaving the basket empty.
  @places-real-order
  Scenario: Successful guest checkout purchase
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    When I click on the "Add to basket" button
    And I wait for the page to settle
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

    # 2026-09-30: confirmed live on staging - ticking "Same as delivery
    # address" swaps the billing address form (and its "Use this address"
    # button) for an address summary with its own Continue button.
    When I click on the "billing same as delivery" element
    And I click on the "billing continue" button
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


  # Logged-in purchase with the account's saved delivery/billing address.
  # Built 2026-09-30 now that the Andy Thornton test account works (see
  # logging-in.feature). The account is shared and its only saved address
  # belongs to another user, so the order is marked as a Velstar test in the
  # delivery notes (CLAUDE.md) rather than by name. Places a real order on
  # staging; @places-real-order keeps it out of production runs.
  @places-real-order
  Scenario: Successful logged-in checkout purchase using saved addresses
    Given I am navigating the page as a "logged in" user
    And I click on the "Allow all cookies" button if present
    When I am on the "pdp" page
    And I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Checkout" button
    Then I should be redirected to the "checkout" page

    # Confirmed live: the signed-in Continue does nothing if clicked the
    # moment the step renders (hydration), so retry until it moves on.
    When I click on the "signed-in Continue" button, retrying until redirected to the "checkout-delivery" page
    And I click on the "1st" "saved address option" element
    And I click on the "saved address continue" button
    Then the "current delivery address" should be displayed
    When I fill in the "delivery phone" input field with "07700900000"
    And I fill in the "delivery notes" input field with "Velstar Test - automated test order, please ignore"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button
    Then I should be redirected to the "checkout-billing" page

    When I click on the "1st" "saved address option" element
    And I click on the "saved address continue" button
    Then I should be redirected to the "checkout-review" page
    # Delivery is priced by postcode, and the saved address belongs to another
    # user of this shared account, so compare against the total the review
    # step itself shows rather than a hard-coded amount (confirmed live: £144.00
    # here vs £158.40 for the guest scenario's NW1 address).
    When I remember the price in "checkout total" as "review total"

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
    And the price in "order total" should equal the remembered "review total"
