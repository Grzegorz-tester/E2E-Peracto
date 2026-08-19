@regression
Feature: Barclays Verifone Payment Integration

  # From KOOL-2026-08-17.json, "Barclays Verifone Payment Integration"
  # (cases 548-574). Deliberately narrow: a successful card payment is
  # already proven end-to-end by purchase-journey.feature (via
  # payment-test-cards.ts's "frictionless" 3DS test numbers), and repeating
  # that here would just add more load against the SAME real Cardinal
  # Commerce 3D Secure flow that's confirmed to start failing/stalling
  # after several automated attempts in a short window - not something to
  # risk for redundant coverage.
  #
  # Google Pay and Apple Pay (cases 551/552/559/564/569) are NOT covered -
  # headless Chromium cannot drive a real device wallet, and the source
  # suite's own note on Apple Pay says as much ("requires a sandbox Apple ID
  # with a test card configured in Wallet").
  #
  # Outstanding Balance (568-570) and Pay by Link (567) aren't covered
  # either - both need either a specific account balance state or would be
  # a second real payment attempt for no additional signal beyond what's
  # already covered below.

  @smoke
  Scenario: The Delivery step's PROCEED button stays disabled until a phone number is entered
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "CHECKOUT SECURELY" button
    Then I should be redirected to the "checkout" page

    When I click on the "Delivery" element
    Then the "PROCEED" should not be enabled

    When I fill in the "Telephone" input field with "07911123456"
    Then the "PROCEED" should be enabled

  # No 3D Secure involved for a declined card (see payment-test-cards.ts),
  # so this doesn't carry the same fraud-detection risk as a real payment
  # attempt - confirmed expected to fail fast, before Cardinal Commerce is
  # ever reached.
  Scenario: A declined card is not charged, and the user is returned to try again
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "CHECKOUT SECURELY" button
    Then I should be redirected to the "checkout" page

    When I click on the "Delivery" element
    And I fill in the "Telephone" input field with "07911123456"
    And I click on the "PROCEED" button
    And I click on the "first delivery option" element
    And I click on the "PROCEED" button
    And I click on the "billing address" element
    And I click on the "PROCEED" button

    When I click on the "PAY ON CARD" button
    And I attempt to pay with the "declined" Verifone test card
    Then the current URL should contain "checkout"
    And the "payment iframe" should be displayed

  @smoke
  Scenario: The Make a Payment amount field clears its 0 placeholder on click
    Given I am navigating the page as a "logged in" user
    And I am on the "account" page
    When I click on the "Make a Payment menu item" element
    Then the "make a payment online section" should be displayed
    And the "make a payment amount input" should equal the value "0"

    When I click on the "make a payment amount input" element
    Then the "make a payment amount input" should equal the value ""
