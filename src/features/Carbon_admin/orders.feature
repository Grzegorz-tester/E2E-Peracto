@carbon_regression

Feature: Orders Page

  Background:
    Given I am navigating the page as a "logged in" user
    When I click on the "Orders" link
    Then I should be redirected to the "orders" page


  Scenario Outline: Filter orders by Order Reference
    When I fill in the "Order Reference" input field with "<order reference>"
    And I click on the "Apply" button
    Then I should see "<entries amount>" "order" displayed
    Examples:
      | order reference | entries amount |
      | 000001          | 1              |
      | 00000           | 2              |
      | 9999999         | 0              |


  Scenario Outline: Filter orders by Email
    When I fill in the "Email" input field with "<email address>"
    And I click on the "Apply" button
    Then I should see "<entries amount>" "order" displayed
    Examples:
      | email address | entries amount |
      | admin@9xb.com | 2              |
      | other@9xb.com | 0              |


#  Scenario Outline: Filter orders by Status
#    When I click on the "Status" dropdown
#    And I click on the "<selected status>" element
#    Then I should see "<entries amount>" "order" displayed
#    Examples:
#      | selected status | entries amount |
#      | Abandoned       | 2              |


  Scenario: Navigate to a specific order
    When I click the "2th" "order" element
#  Then

  Scenario: Resetting the filters


  Scenario: Export Order Data
    When I click on the "Export Order Data" button
#    Then