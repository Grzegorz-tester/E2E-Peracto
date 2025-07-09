@Panelco_regression
Feature: Basket page

  Background:
    Given I am navigating the page as a "logged in" user
    When I am on the "basket" page


  Scenario: Verify basket elements
    Then I should be presented with a "order total price" "0.00"


  Scenario Outline: Product search functionality
    And I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    Examples:
      | product       |
      | Greg's Mirror |


  Scenario Outline: Verify changing the amount of a product in the basket
    And I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    Examples:
      | product       |
      | Greg's Mirror |


  Scenario Outline: Verify removing products from the basket
    And I fill in the "Search products" input field with "<product1>"
    And I click on the "first search result" element
#    And I fill in the "Search products" input field with "<product2>"
#    And I click on the "second search result" element
    Examples:
      | product1      | product2 |
      | Greg's Mirror | Solas    |


  Scenario Outline: Verify opening and closing the "Specifications" draw
    Then the "specification draw" should not be displayed
    When I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    And I click on the "Specification" button
    Then the "specification draw" should be displayed
    When I click on the "close" button
    Then the "specification draw" should not be displayed
    Examples:
      | product       |
      | Greg's Mirror |


  Scenario Outline: Verify opening and closing the "Products you may also need" draw
    Then the "you may also need draw" should not be displayed
    When I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    And I click on the "Products you may also need" button
    Then the "you may also need draw" should be displayed
    When I click on the "close" button
    Then the "you may also need draw" should not be displayed
    Examples:
      | product       |
      | Greg's Mirror |