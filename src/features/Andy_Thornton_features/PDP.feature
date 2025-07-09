@Andy_Thornton_regression
Feature: Verify PDP functionality


  Scenario: Verify PDP elements
    Given I am on the "pdp" page
    Then the "product image" should be displayed
    And the "product name" should be displayed
#    And the "product SKU" should be displayed
    And the "product features" should be displayed
    And the "product specifications" should be displayed
#    And the "product price" should be displayed
#    And the "stock level" should be displayed
#    And the "delivery time" should be displayed
#    And the "warranty time" should be displayed
#    And the "View details" should be displayed
    And the "quantity picker" should be displayed
    And the "Add to basket" should be displayed
    And the "Add to quotes" should be displayed