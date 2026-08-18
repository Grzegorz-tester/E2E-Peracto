@regression
Feature: Guest purchase journey

  # Ported from Insinkerator_EU's guest-purchase-journey.feature.
  #
  # WARNING: this scenario completes a REAL CyberSource test-mode payment
  # and creates a REAL, permanent order on staging every time it runs. Do
  # not repeat it across retries/configs.
  #
  # CONFIRMED (live, 2026-08-15): the generic "default" CyberSource test
  # card (4111 1111 1111 1111, Visa) is NOT accepted by this UK site's
  # merchant account - it consistently returns a real "Sorry, there was an
  # error when processing your payment" from CyberSource itself. The
  # "mastercard" test card (5200 0000 0000 2235) works correctly end to
  # end and completes a real order - use that one for this project instead
  # of "default" (which is fine for Insinkerator_EU).
  #
  # Also note: a cookie-consent banner on this site can reappear mid-flow
  # (not just on a fresh page load) and, being a real fixed-position
  # overlay, can literally intercept a click's real screen coordinates even
  # under Playwright's force:true - confirmed live at several points below
  # (Secure Checkout, Billing continue, before paying) and defended against
  # by re-dismissing it immediately before each such click.

  @smoke
  Scenario: User can complete a guest purchase through to the thank-you page
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I am on the "sink-flange-pdp" page
    And I click on the "Accept cookies" button if present
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button
    And the "basket count" should contain the text "1"

    When I am on the "basket" page
    And I click on the "Accept cookies" button if present
    And I click on the "Secure Checkout" button
    Then I should be redirected to the "checkout-sign-in" page

    When I click on the "Guest checkout" element
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Guest continue" button
    Then I should be redirected to the "checkout-delivery" page
    And the "address first name" should be displayed

    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I search for an address in the "address line 1" field using the term "10 Downing Street"
    And I click on the "Use this address" button
    And I fill in the "Phone number" input field with "07911123456"
    And I click on the "Accept cookies" button if present
    And I click on the "1st" "delivery method option" element
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    When I click on the "Accept cookies" button if present
    And I check the "same as delivery checkbox", retrying until it is checked
    And I click on the "Billing continue" button
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed

    When I click on the "Accept cookies" button if present
    And I pay with the "mastercard" CyberSource test card
    Then I should be redirected to the "checkout-thank-you" page
    And the "thank you header" should equal text "Thank you for your order"
    And the "order reference" should contain the text "Order No."
    And the "order confirmation email" should contain the stored guest email
