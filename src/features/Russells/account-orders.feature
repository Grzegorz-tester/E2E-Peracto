@regression
Feature: Account orders

  # Depends on logged-in-purchase-journey.feature having already placed a
  # real order against the "logged in" test account - that account
  # permanently has at least one real order from that scenario.

  Background:
    Given I am navigating the page as a "logged in" user
    And I click on the "Accept cookies" button if present
    And I am on the "account-orders" page

  @smoke
  Scenario: User can view a real order in the Orders page
    Then the "Orders header row" should contain the text "Order Number"
    And the "Orders header row" should contain the text "Placed On"
    And the "Orders header row" should contain the text "Amount"
    And the "Order reference filter" should be displayed
    And the "Order amount filter" should be displayed
    And the "first order row" should be displayed
    And the "first order amount" should contain the text "£"

    When I remember the text of "first order reference" as "order reference"
    And I click on the "first order row" element
    Then I should be redirected to the "account-order-detail" page
    And the "Order reference" should contain the remembered "order reference"
    And the "Order confirmation email" should contain the "logged in" user's email
