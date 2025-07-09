
Feature: Place Order (Basket) page

  Background:
    Given I am navigating the page as a "logged in" user
    When I am on the "place-order" page


  Scenario: Verify empty basket elements
    Then I should be presented with a "order total price" "0.00"
    And the "no items message" should be displayed
    And the "PLACE ORDER" should not be enabled


  Scenario Outline: Existing product search functionality
    And I fill in the "Search products" input field with "<product>"
    Then the "search results" should be displayed
    And the "first search result" should be displayed
    When I click on the "X" button
    Then the "search results" should not be displayed
    Examples:
      | product  |
      | Vanquish |


  Scenario Outline: Non existing product search functionality
    And I fill in the "Search products" input field with "<product>"
    Then the "search results" should be displayed
    And the "first search result" should not be displayed
    And the "No results found message" should be displayed
    When I click on the "X" button
    Then the "search results" should not be displayed
    Examples:
      | product              |
      | non existing product |


  Scenario Outline: Verify changing the quantity of a product in the basket
    And I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    Examples:
      | product  |
      | Vanquish |


  Scenario Outline: Verify removing products from the basket
    And I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's price" should be displayed
    And the "product's price" should contain the text "<price>"
    When I fill in the "Search products" input field with "<product>"
    And I click on the "second search result" element
    And I click on the "second variant" element
    And I click on the "Add to basket" button
    Examples:
      | product  | price |
      | Vanquish | 84.00 |


#  Scenario Outline: Verify opening and closing the "Specifications" draw
#    Then the "specification draw" should not be displayed
#    When I fill in the "Search products" input field with "<product>"
#    And I click on the "first search result" element
#    And I click on the "Specification" button
#    Then the "specification draw" should be displayed
#    When I click on the "close" button
#    Then the "specification draw" should not be displayed
#    Examples:
#      | product |
#      | Vanquish    |
#
#
#  Scenario Outline: Verify opening and closing the "Products you may also need" draw
#    Then the "you may also need draw" should not be displayed
#    When I fill in the "Search products" input field with "<product>"
#    And I click on the "first search result" element
#    And I click on the "Products you may also need" button
#    Then the "you may also need draw" should be displayed
#    When I click on the "close" button
#    Then the "you may also need draw" should not be displayed
#    Examples:
#      | product |
#      | Vanquish   |