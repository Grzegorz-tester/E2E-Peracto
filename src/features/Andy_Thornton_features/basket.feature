@regression
Feature: Basket page

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): see
  # PDP.feature - an undismissed Cookiebot banner intercepts "Add to
  # basket" on a fresh consent-less context, leaving the basket empty.
  # Also see PDP.feature's second note: even with the banner dismissed,
  # navigating to "basket" too fast after clicking can still race the
  # add-to-basket request itself - "I wait for the page to settle" first.

  Background:
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    When I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket item" should be displayed
    # 2026-09-30: confirmed live on staging - the quantity +/- buttons render
    # before the basket page has hydrated, so a click straight away does
    # nothing (2/2 stayed at qty 1); after a ~3s settle it works (2/2).
    And I wait for the page to settle

  Scenario: Verify basket elements
    Then the "basket total" should be displayed
    And the "basket subtotal" should be displayed

  @smoke
  Scenario: Verify changing the amount of a product in the basket
    When I increment the basket quantity and the total should update correctly
    And I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"
    And the "quantity minus" should not be enabled

  Scenario: Verify removing products from the basket
    When I click on the "remove basket line" button
    Then the "basket item" should not be displayed

  Scenario: Verify an invalid promotional code is rejected
    When I click on the "promotional code" button
    And I fill in the "promo code input" input field with "INVALIDCODE123"
    And I click on the "promotional code" button
    Then the "promo code form" should contain the text "This is not a valid promo code."


  # Backed by a Velstar-owned promotion created for this suite on 2026-09-30
  # in the Andy Thornton STAGING admin: promotion 78 "Velstar Test 1% Off",
  # 1% off everything, no conditions, no end date, code VELSTARTEST1 (max
  # uses and uses per email both 999999). It only exists on staging - skip
  # on production. Don't delete it as a "leftover test entity".
  @not-on-production
  Scenario: Verify a valid promotional code applies its discount
    When I click on the "promotional code" button
    And I fill in the "promo code input" input field with "VELSTARTEST1"
    And I click on the "promotional code" button
    Then the "promotions container" should contain the text "Velstar Test 1% Off"
    And the "promotions container" should contain the text "Velstar test promotion applied"
    # 1% of £122.40 is £1.224; confirmed live the site rounds the discount UP
    # (to £1.23, same as MIPA), so the total is £121.17, not £121.18.
    And the "basket total" should contain the text "121.17"
