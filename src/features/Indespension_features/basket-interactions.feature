@regression
Feature: Basket interactions

  # Full rewrite - the previous version searched for a product called
  # "Vanquish" (an HIB SKU, not sold here) via an on-page search box that
  # doesn't exist on Indespension's real /basket page, had no @regression/
  # @smoke tag so it never actually ran, and its quantity-change/remove
  # scenarios ended with no assertions at all. Uses a guest session
  # throughout (no login) so the basket is always a fresh, empty one for
  # this browser context - a logged-in account's basket is server-side and
  # persists across runs, which would make "start from empty" unreliable.

  Background:
    Given I am navigating the page as a "guest" user
    And I am on the "blueline-trailer-pdp" page

  Scenario: Adding a product to the basket
    When I click on the "Add to basket" button
    Then the "added to basket confirmation" should be displayed
    When I press the Escape key
    Then the "basket count" should contain the text "1"

  Scenario: Changing the quantity of a basket item updates its total correctly
    When I click on the "Add to basket" button
    Then the "added to basket confirmation" should be displayed
    When I press the Escape key
    And I click on the "Basket" icon
    Then I should be redirected to the "basket" page
    When I increment the basket quantity and the total should update correctly
    And I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"

  Scenario: Removing a product empties the basket
    When I click on the "Add to basket" button
    Then the "added to basket confirmation" should be displayed
    When I press the Escape key
    And I click on the "Basket" icon
    Then I should be redirected to the "basket" page
    When I click on the "Remove items" element
    Then the "no items message" should be displayed
