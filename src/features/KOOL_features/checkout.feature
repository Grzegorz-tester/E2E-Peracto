@regression
Feature: Checkout - Delivery, Billing, and Review and Payment

  # From KOOL-2026-08-17.json, "Storefront > Checkout" (cases 300, 339,
  # 343-344, 367-369) and its Delivery/Billing sub-suites (the address
  # selection/PROCEED flow, already proven end-to-end by
  # purchase-journey.feature). Runs as the "logged in" user on the
  # "cable-pdp" page, the same reliable combination used throughout this
  # project - guest pricing/add-to-basket is confirmed flaky (see
  # pdp.feature), so the guest Sign In step (email validation, "proceed
  # without an address saved") isn't covered here.
  #
  # NOT YET CONFIRMED LIVE, deferred rather than guessed at: the "Add new
  # address" form's Submit button stayed disabled after filling every
  # visible required field by hand - either a field/validation this wasn't
  # accounting for, or a real bug; and Click & Collect's branch search
  # returns a 200 from its own API but never rendered any results for
  # either a city name or postcode-prefix search term tried live.

  Background:
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    And I click on the "Accept cookies" button if present
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "CHECKOUT SECURELY" button
    Then I should be redirected to the "checkout" page

  @smoke
  Scenario: Completing Delivery and Billing reaches Review and Payment with the order summary
    When I click on the "Delivery" element
    And I fill in the "Telephone" input field with "07911123456"
    And I click on the "PROCEED" button
    Then the "delivery options" should be displayed

    When I click on the "first delivery option" element
    And I click on the "PROCEED" button
    When I click on the "billing address" element
    And I click on the "PROCEED" button

    Then the "review and payment content" should be displayed
    And the "review and payment content" should contain the text "PAY ON ACCOUNT"
    And the "review and payment content" should contain the text "PAY ON CARD"

  Scenario: Editing the delivery address from Review and Payment returns to the Delivery step
    When I click on the "Delivery" element
    And I fill in the "Telephone" input field with "07911123456"
    And I click on the "PROCEED" button
    And I click on the "first delivery option" element
    And I click on the "PROCEED" button
    And I click on the "billing address" element
    And I click on the "PROCEED" button
    Then the "review and payment content" should be displayed

    When I click on the "edit delivery address link" element
    Then the "delivery type options" should be displayed
