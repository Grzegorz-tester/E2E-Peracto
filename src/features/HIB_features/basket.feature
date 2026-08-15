
Feature: Place Order (Basket) page

  Background:
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "place-order" page


  Scenario: Verify empty basket elements
    Then I should be presented with a "order total price" "0.00"
    And the "no items message" should be displayed
    And the "PLACE ORDER" should not be enabled


  Scenario Outline: Existing product search functionality
    And I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    Then the "search results" should be displayed
    And the "first search result" should be displayed
    When I click on the "X" button
    Then the "search results" should not be displayed
    Examples:
      | product  |
      | Vanquish |


  Scenario Outline: Non existing product search functionality
    And I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
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
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's total price" should contain the text "<price>"
    When I fill in the "Quantity selector" input field with "<new quantity>"
    And I click on the "Update" button
    Then the "Quantity selector" should equal the value "<new quantity>"
    And the "product's total price" should contain the text "<new total>"
    And the "order total price" should contain the text "<new total>"
    Examples:
      | product  | price | new quantity | new total |
      | Vanquish | 84.00 | 3            | 252.00    |


  Scenario Outline: Verify removing products from the basket
    And I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's price" should be displayed
    And the "product's price" should contain the text "<price>"
    And the "Quantity selector" should equal the value "1"
    And the "product's total price" should contain the text "<price>"
    When I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    And I click on the "second search result" element
    And I click on the "second variant" element
    And I click on the "Add to basket" button
    Examples:
      | product  | price |
      | Vanquish | 84.00 |


 Scenario Outline: Verify opening and closing the "Specifications" draw
   Then the "specification draw" should not be displayed
   When I fill in the "Search products" input field with "<product>"
   And I wait for the search results to update
   And I click on the "first search result" element
   And I click on the "Specification" button
   Then the "specification draw" should be displayed
   When I click on the "close" button
   Then the "specification draw" should not be displayed
   Examples:
     | product |
     | Vanquish    |


 Scenario Outline: Verify opening and closing the "Products you may also need" draw
   Then the "you may also need draw" should not be displayed
   When I fill in the "Search products" input field with "<product>"
   And I wait for the search results to update
   And I click on the "first search result" element
   And I click on the "Products you may also need" button
   Then the "you may also need draw" should be displayed
   When I click on the "close" button
   Then the "you may also need draw" should not be displayed
   Examples:
     | product |
     | Vanquish   |


 # NOTE: "Add to basket - you may also need" locator is inferred from the
 # site's existing "//button[text()='Add to basket']" convention, scoped
 # inside the "You may also need" draw - it hasn't been confirmed against
 # the live site (staging was unresponsive/timing out for this drawer's
 # contents at the time this was written), so verify it once the site is
 # stable before trusting this scenario.
 Scenario Outline: Verify a recommended product can be added to the order from the "Products you may also need" draw
   And I fill in the "Search products" input field with "<product>"
   And I wait for the search results to update
   And I click on the "first search result" element
   And I slowly click on the "first variant" element
   And I slowly click on the "Add to basket" button
   And I click on the "Products you may also need" button
   Then the "you may also need draw" should be displayed
   When I click on the "Add to basket - you may also need" button
   Then the "second basket item" should be displayed
   Examples:
     | product  |
     | Vanquish |