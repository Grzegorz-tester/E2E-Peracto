@regression

Feature: Operations in the users account


  Scenario: Verify:
  - the presence of DASHBOARD tab elements
  - presence of the orders table
  - redirection to "Stock Check & Quick Order"
  - redirection to "All Orders"
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "DASHBOARD" tab
    Then the "Orders table" should be displayed
    When I click on the "Stock Check & Quick Order" button
    Then I should be redirected to the "place-order" page
    When I click on the "Back to Portal" button
    Then I should be redirected to the "account" page
#    When I click on the "Contact Us" button
#    Then I should be redirected to the "" page
    When I click on the "View all and search" link
    Then I should be redirected to the "account-orders" page

  Scenario: Verify:
  - a presence of the PROFILE tab elements
  - if the not editable fields are disabled
  - if the editable fields are not disabled
  - if the required fields are not empty
    Given I am navigating the page as a "logged in" user
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
    When I am on the "account" page
    And I click on the "ADDRESS BOOK" tab
    Then I should be redirected to the "account-address-book" page
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed


  Scenario: Verify:
  - a presence of ORDERS tab elements

    Given I am navigating the page as a "logged in" user
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
    When I am on the "account" page
    And I click on the "STOCK CHECK & QUICK ORDER" tab
    Then I should be redirected to the "place-order" page

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