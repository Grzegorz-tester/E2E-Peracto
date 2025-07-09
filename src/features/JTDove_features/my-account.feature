
Feature: Operations in the users account


  Scenario: Check the presence of Dashboard elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Dashboard" tab

  Scenario: Check the presence of Profile elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Profile" tab
    Then I should be redirected to the "account-profile" page

  Scenario: Check the presence of Address book elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Address book" tab
    Then I should be redirected to the "account-address-book" page

  Scenario: Check the presence of Orders elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Invoices" tab
    Then I should be redirected to the "invoices" page

  Scenario: Check the presence of Quotes elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "My List" tab
    Then I should be redirected to the "wishlists" page

  Scenario: Check the presence of Quotes elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Make a Payment" tab
    Then I should be redirected to the "make-a-payment" page

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