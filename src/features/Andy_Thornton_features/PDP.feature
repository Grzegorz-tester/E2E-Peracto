@regression
Feature: Verify PDP functionality

  Scenario: Verify PDP elements
    Given I am on the "pdp" page
    Then the "product image" should be displayed
    And the "product name" should be displayed
    And the "product SKU" should be displayed
    And the "product price" should be displayed
    And the "quantity picker" should be displayed
    And the "Add to basket" should be displayed
    And the "Description tab" should be displayed
    And the "Specifications tab" should be displayed
    And the "Downloads tab" should be displayed

  Scenario: Verify adding a product to the basket
    Given I am on the "pdp" page
    When I click on the "Add to basket" button
    And I am on the "basket" page
    Then the "basket item name" should contain the text "Vienna Stackable Side Chair"
