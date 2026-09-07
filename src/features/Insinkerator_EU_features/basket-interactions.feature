@regression
Feature: Basket interactions

  # Ported from P3Playwright's insinkerator_eu/tests/basket-checkout/
  # basket-interactions.test.ts. No login and no real order involved.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    And I am on the "sink-flange-pdp" page
    And I click precisely on the "Add to basket" button, dismissing the "Accept cookies" if it interferes
    And the "added to basket confirmation" should be displayed
    And I click precisely on the "Continue shopping" button, dismissing the "Accept cookies" if it interferes
    And the "basket count" should contain the text "1"
    And I am on the "basket" page

  Scenario: User can adjust the basket quantity, with Minus disabled at quantity 1
    When I increment the basket quantity and the total should update correctly
    And I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"
    And the "quantity minus" should not be enabled

  # NOTE: as of 2026-09-05, the live promotion form applies whatever code is
  # typed with no validation at all - confirmed live (headed run, watched):
  # an invalid code produces no error and no visible change whatsoever, not
  # even a failed request. There is currently no way to exercise a genuine
  # "invalid code" error path. Instead this exercises the one deterministic,
  # known-valid code set up for automation ("PROMO10" -> "Automation QA Test
  # Promo", success message "Promotion PROMO10 is now applied"). Revert to
  # (or add back) an invalid-code scenario once real validation exists.
  Scenario: User can successfully apply a valid promo code
    When I click precisely on the "promo code toggle" button, dismissing the "Accept cookies" if it interferes
    And I fill in the "promo code input" input field with "PROMO10"
    And I click precisely on the "promo code apply" button, dismissing the "Accept cookies" if it interferes
    Then the "promo code success message" should be displayed
