@regression
Feature: Basket interactions

  Background:
    Given I navigate directly to the path "/products/walterscheid-universal-joint-32-x-76mm-standard-duty"
    And I click on the "Accept cookies" button if present
    And I click on the "Add to Basket" button
    And I am on the "basket" page
    And the "basket item" should be displayed

  @smoke
  Scenario: User can adjust the basket quantity, with Minus disabled at quantity 1
    When I increment the basket quantity and the total should update correctly
    And I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"
    And the "quantity minus" should not be enabled

  Scenario: User sees an error when applying an invalid promo code
    When I click on the "promotional code" button
    And I fill in the "promo code input" input field with "INVALIDCODE123"
    And I click on the "promotional code" button
    Then the "promo code form" should contain the text "This is not a valid promo code."

  Scenario: User can apply a valid promo code and the discount recalculates the total
    When I click on the "promotional code" button
    And I fill in the "promo code input" input field with "PROMO50"
    And I click on the "promotional code" button
    Then the "promotions container" should contain the text "promotion applied"
