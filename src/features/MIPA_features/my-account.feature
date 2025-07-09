@MIPA_regression

Feature: Operations in the users account


  Scenario: Verify:
  - the presence of Dashboard tab elements
  - presence of the orders table
  - redirection to "All Orders"
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Dashboard" tab
    Then the "Recent Orders table" should be displayed
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed
    Then I should be redirected to the "account" page
    When I click on the "orders - View all" link
    Then I should be redirected to the "account-orders" page

  Scenario: Verify:
  - a presence of the Profile tab elements
  - if the not editable fields are disabled
  - if the editable fields are not disabled
  - if the required fields are not empty
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Profile" tab
    Then I should be redirected to the "account-profile" page

    And the "Email" should not be enabled
    And the "Email" should not equal the value ""

    And the "First name" should be enabled
    And the "First name" should not equal the value ""

    And the "Last name" should be enabled
    And the "Last name" should not equal the value ""

    And the "Contact number" should be enabled

    And the "Save Changes" should be enabled


  Scenario: Verify:
  - a presence of Address Book tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Address Book" tab
    Then I should be redirected to the "account-address-book" page
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed


  Scenario: Verify:
  - a presence of Orders tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Orders" tab
    Then I should be redirected to the "account-orders" page
    And the "Order picker" should be displayed
    And the "Date picker" should be displayed
    And the "Total picker" should be displayed
    And the "Refresh" should be displayed
    And the "Orders table" should be displayed

  Scenario: Verify:
  - a presence of Wishlist tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Wishlist" tab
    Then I should be redirected to the "account-wishlist" page
    And the "search bar" should be displayed
    And the "Refresh" should be displayed
    And the "Create a new Wishlist" should be displayed
    And the "Wishlists table" should be displayed


#  Scenario: Check the presence of My details in the Profile tab
#    Given I am logged in user
#    When I press the PROFILE tab
#    Then I should see all of My Details
#      | Field Name     | Value            |
#      | Email          | g.hajduk@9xb.com |
#      | First name     | Grzegorz         |
#      | Last name      | Test             |
#      | Company Name   | 9xb              |
#      | Account Number | CEU012           |
#      | Currency       | GBP              |