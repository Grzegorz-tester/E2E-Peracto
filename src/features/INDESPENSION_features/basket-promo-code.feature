@regression
Feature: Basket promotion codes

  # IND-729 (Peracto API upgrade) case 327. Guest basket, so the shared
  # logged-in basket is untouched.
  #
  # The valid code is backed by a Velstar-owned fixture on STAGING only:
  # promotion 15 "Velstar Test 1% Off" (identifier velstar-test-1-percent,
  # code VELSTARTEST1, 999999 uses, no conditions, priority 999), created via
  # the admin API on 2026-11-13. Do not delete it. It is code-only, so it never
  # auto-applies to other baskets. It does not exist on production.
  #
  # CONFIRMED 2026-11-13 (staging): the basket shows the promotion NAME as a
  # badge plus a Discount row; £8,868.00 became £8,779.32 (exactly 1%).

  Background:
    Given I am navigating the page as a "guest" user
    And I am on the "blueline-trailer-pdp" page
    And I wait for the page to settle
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears
    And I am on the "basket" page
    And I wait for the page to settle
    When I click on the "promo code toggle" button

  @not-on-production
  Scenario: A valid promotion code applies its discount to the basket total
    When I fill in the "promo code input" input field with "VELSTARTEST1"
    And I click on the "promo code apply" button
    Then the "applied promotion" should contain the text "Velstar Test 1% Off"
    And the "basket discount" should be displayed
    And the "basket total" price should be "1"% less than the "order subtotal price" price

  Scenario: An invalid promotion code is rejected and the total is unchanged
    When I fill in the "promo code input" input field with "VELSTAR-NOT-A-REAL-CODE"
    And I click on the "promo code apply" button
    Then the "promo code form" should contain the text "This is not a valid promo code."
    And the "basket discount" should not be displayed
    And the "basket total" price should equal the "order subtotal price" price
