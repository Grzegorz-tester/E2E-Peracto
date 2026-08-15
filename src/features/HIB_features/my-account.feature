@regression

Feature: Operations in the users account


  Scenario: Verify:
  - the presence of DASHBOARD tab elements
  - presence of the orders table
  - redirection to "Stock Check & Quick Order"
  - redirection to "All Orders"
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "DASHBOARD" tab
    Then the "Orders table" should be displayed
    When I click on the "Stock Check & Quick Order" button
    Then I should be redirected to the "place-order" page
    When I click on the "Back to Portal" button
    Then I should be redirected to the "account" page
    # "Contact Us" redirect target was never filled in here (asserted an
    # empty pageId) - needs live investigation of what it actually does
    # (support page? mailto link? modal?) before it can be tested properly.
    When I click on the "View all and search" link
    Then I should be redirected to the "account-orders" page

  Scenario: Verify:
  - a presence of the PROFILE tab elements
  - if the not editable fields are disabled
  - if the editable fields are not disabled
  - if the required fields are not empty
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "PROFILE" tab
    Then I should be redirected to the "account-profile" page

    And the "Email" should not be enabled
    And the "Email" should not equal the value ""

    And the "First name" should not be enabled
    And the "First name" should not equal the value ""

    And the "Last name" should not be enabled
    And the "Last name" should not equal the value ""

    And the "Contact number" should be enabled

    And the "Company Name" should not be enabled
    And the "Company Name" should not equal the value ""

    And the "Account Number" should not be enabled
    And the "Account Number" should not equal the value ""

    And the "Currency" should not be enabled
    And the "Currency" should not equal the value ""

    And the "Save Changes" should be enabled


  Scenario: Verify:
  - a presence of ADDRESS BOOK tab elements

    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "ADDRESS BOOK" tab
    Then I should be redirected to the "account-address-book" page
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed


  Scenario: Verify:
  - a presence of ORDERS tab elements

    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "ORDER HISTORY" tab
    Then I should be redirected to the "account-orders" page
    And the "Order picker" should be displayed
    And the "Date picker" should be displayed
    And the "Refresh" should be displayed
    And the "Orders table" should be displayed


  Scenario: Verify:
  - the STOCK CHECK & QUICK ORDER tab functionality

    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "STOCK CHECK & QUICK ORDER" tab
    Then I should be redirected to the "place-order" page


  # End-to-end Stock Check & Quick Order journey, starting from My Account
  # rather than navigating to place-order directly (see basket.feature for
  # the individual pieces tested in isolation).
  Scenario Outline: Search, add, adjust quantity and add a recommended product via Stock Check & Quick Order
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "STOCK CHECK & QUICK ORDER" tab
    Then I should be redirected to the "place-order" page
    When I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    Then the "search results" should be displayed
    When I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's price" should contain the text "<price>"
    And the "Quantity selector" should equal the value "1"
    And the "product's total price" should contain the text "<price>"
    When I fill in the "Quantity selector" input field with "<new quantity>"
    And I click on the "Update" button
    Then the "product's total price" should contain the text "<new total>"
    And the "order total price" should contain the text "<new total>"
    When I click on the "Products you may also need" button
    Then the "you may also need draw" should be displayed
    When I click on the "Add to basket - you may also need" button
    Then the "second basket item" should be displayed
    Examples:
      | product  | price | new quantity | new total |
      | Vanquish | 84.00 | 3            | 252.00    |