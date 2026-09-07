@Andy_Thornton_regression
Feature: Basket page

  Background:
    Given I am on the "pdp" page
    When I click on the "Add to basket" button
    And I am on the "basket" page
    Then the "basket item" should be displayed

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
