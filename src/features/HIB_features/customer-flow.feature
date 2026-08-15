@smoke
@regression
Feature: Product purchase flow

  # IMPORTANT: never create real orders for the HIB project (see README).
  # This scenario deliberately stops right before the final "PLACE ORDER"
  # button, which submits the order for real - it only exercises the flow
  # up to that point (login, search, add to basket, delivery/billing
  # address, phone/PO number) and confirms the order-submission step was
  # reached, without ever clicking it.

  Scenario: User can proceed through checkout up to (but not including) placing the order
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Portal" icon
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "home" page
    When I click on the "header logo" element
    Then I should be redirected to the "home" page
    When I fill in the "Search products" input field with "Solas"
    And I wait for the search results to update
    And I click on the "first search result" element
    Then I should be redirected to the "solas" page
    And I click on the "first variant" button
    And I click on the "Add to basket" button
    And I click on the "Place Order" button
    Then I should be redirected to the "place-order" page
    When I click on the "PLACE ORDER" button
    And I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    When I fill in the "Phone" input field with "07377777777"
    When I fill in the "PO Number" input field with "1"
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    Then the "PLACE ORDER" should be displayed
