@Panelco_regression

Feature: Operations in the users account


  Scenario: Verify:
  - the presence of DASHBOARD tab elements
  - redirection to the "Address book"
  - redirection to a specific order
    Given I am navigating the page as a "logged in" user
    When I am on the "portal" page
    And I click on the "Dashboard" tab
    Then the "Delivery Address" should be displayed
    And the "Orders table" should be displayed
    When I click on the "View all" button
    Then I should be redirected to the "portal-address-book" page
#    When I click on the "Dashboard" tab
#    And I click on the "first order" element
#    Then I should be redirected to the "quotes" page


  Scenario: Verify:
  - a presence of the PROFILE tab elements
  - if the not editable fields are disabled
  - if the editable fields are not disabled
  - if the required fields are not empty
    Given I am navigating the page as a "logged in" user
    When I am on the "portal" page
    And I click on the "Profile" tab
    Then I should be redirected to the "portal-profile" page

    And the "Email" should not be enabled
    And the "Email" should not equal the value ""

    And the "First name" should be enabled
    And the "First name" should not equal the value ""

    And the "Last name" should be enabled
    And the "Last name" should not equal the value ""

    And the "Contact number" should be enabled
    And the "Branch" should not equal the value "Please select..."
    And the "Save Changes" should be enabled


  Scenario: Verify:
  - a presence of ADDRESS BOOK tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "portal" page
    And I click on the "Address Book" tab
    Then I should be redirected to the "portal-address-book" page
    And the "Delivery Address" should be displayed


  Scenario: Verify:
  - a presence of QUOTES tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "portal" page
    And I click on the "Quotes" tab
    Then I should be redirected to the "portal-quotes" page
    And the "Order picker" should be displayed
    And the "Date picker" should be displayed
    And the "Refresh" should be displayed
    And the "Orders table" should be displayed



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