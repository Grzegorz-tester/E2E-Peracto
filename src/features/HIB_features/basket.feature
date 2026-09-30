@regression
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
    # "basket subtotal", not "order total price": confirmed live on
    # feature-hib-170 (2026-09-28) that a 10% "Total discount" line now
    # appears (Subtotal £2,247.00, discount £224.70, RRP Total £2,022.30), so
    # the RRP total no longer equals the line total. The subtotal is what
    # reflects the quantity change being tested.
    And the "basket subtotal" should contain the text "<new total>"
    Examples:
      | product  | price | new quantity | new total |
      | Vanquish | 749.00 | 3            | 2,247.00  |


  # 2026-09-29: this feature had no @regression tag, so it had never run in
  # a regression. On its first run, 4 of 8 scenarios were stale. Rewritten
  # against feature-hib-170 (confirmed live): the first "Vanquish" hit is now
  # the £749.00 Vanquish Bathroom Cabinet, the basket line's "Specification"
  # and "Products you may also need" buttons only appear once a product is in
  # the basket, and the "removing" scenario never actually removed anything.
  Scenario Outline: Verify removing products from the basket
    And I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's price" should contain the text "<price>"
    And the "Quantity selector" should equal the value "1"
    When I click on the "Remove items" element
    Then the "no items message" should be displayed
    And the "basket item" should not be displayed
    And the "PLACE ORDER" should not be enabled
    Examples:
      | product  | price  |
      | Vanquish | 749.00 |


  Scenario Outline: Verify opening and closing the "Specifications" draw
    When I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "specification draw" should not be displayed
    When I click on the "Specification" button
    Then the "specification draw" should be displayed
    When I click on the "close" button
    Then the "specification draw" should not be displayed
    Examples:
      | product  |
      | Vanquish |


  Scenario Outline: Verify opening and closing the "Products you may also need" draw
    When I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "you may also need draw" should not be displayed
    When I click on the "Products you may also need" button
    Then the "you may also need draw" should be displayed
    And the "View Options - you may also need" should be displayed
    When I click on the "close" button
    Then the "you may also need draw" should not be displayed
    Examples:
      | product  |
      | Vanquish |

  # Adding a recommended product from the drawer is covered end to end by
  # my-account.feature's Stock Check & Quick Order journey: the drawer's
  # recommendations are multi-variant, so they link to their own PDP
  # ("View Options") rather than offering an inline Add to basket.
