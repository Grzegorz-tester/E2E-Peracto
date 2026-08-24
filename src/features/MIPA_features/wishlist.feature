@MIPA_regression
Feature: Wishlist ("My Lists")

  # New coverage (previously none existed). MIPA calls this feature
  # "My Lists" in its own UI/nav, not "Wishlist" - confirmed live.

  Scenario: View an existing wishlist and add its items to the basket
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I click on the "Clear Basket" button if present
    When I am on the "account-wishlist" page
    Then the "Wishlists table" should be displayed
    When I click on the "1st" "wishlist add to basket" element
    Then I should be redirected to the "basket" page
    And the "basket item" should be displayed


  # "Add to List" on the PDP adds to an EXISTING list (picked from a
  # dropdown, defaulting to the account's first list) - confirmed live,
  # it is not a "create new list" flow. Creating a new list is its own
  # separate action on the "My Lists" page itself (the "+ Create a new
  # List" link), not exercised here to avoid accumulating throwaway lists
  # on every regression run.
  Scenario: Add a product to an existing wishlist from the PDP
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "Add to List" button
    Then the "added to list modal" should be displayed
    When I click on the "Add to Wishlist confirm button" element
    Then the "added to list modal" should not be displayed
