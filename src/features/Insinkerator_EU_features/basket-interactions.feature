@regression
Feature: Basket interactions

  # Ported from P3Playwright's insinkerator_eu/tests/basket-checkout/
  # basket-interactions.test.ts. No login and no real order involved.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    And I am on the "sink-flange-pdp" page
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button
    And the "basket count" should contain the text "1"
    And I am on the "basket" page

  Scenario: User can adjust the basket quantity, with Minus disabled at quantity 1
    When I increment the basket quantity and the total should update correctly
    And I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"
    And the "quantity minus" should not be enabled

  Scenario: User sees an error when applying an invalid promo code
    When I click on the "promo code toggle" button
    And I fill in the "promo code input" input field with "INVALIDCODE123"
    And I click on the "promo code toggle" button
    Then the "promo code error" should be displayed
