@regression
Feature: Wishlist ("My Lists")

  # New coverage (previously none existed). MIPA calls this feature
  # "My Lists" in its own UI/nav, not "Wishlist" - confirmed live.

  Scenario: View an existing wishlist and add its items to the basket
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I wait for the page to settle
    And I clear the basket
    When I am on the "account-wishlist" page
    Then the "Wishlists table" should be displayed
    When I click on the "1st" "wishlist add to basket" element
    Then I should be redirected to the "basket" page
    And I wait for the page to settle
    And the "basket item" should be displayed


  # "Add to List" on the PDP adds to an EXISTING list, picked from a
  # dropdown that defaults to the account's newest list (confirmed live
  # 2026-10-01). Creating a new list from the PDP is covered in
  # pdp.feature, and from this page in the scenario below.
  Scenario: Add a product to an existing wishlist from the PDP
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "Add to List" button
    Then the "added to list modal" should be displayed
    When I click on the "Add to Wishlist confirm button" element
    Then the "added to list modal" should not be displayed


  # Confirmed live (staging, 2026-10-01):
  # - "+ Create a new List" opens a modal with one name input and an
  #   icon-only submit button; creating redirects straight to the new
  #   list's own page (/account/wishlists/<id>).
  # - Search only filters once SEARCH is clicked, not as you type.
  # - Each row's last cell is its Delete button, which opens a "Delete
  #   Wishlist" confirm dialog (DELETE /wishlists/<id> -> 204).
  # The list is named "qa-<timestamp>" and deleted again in the same
  # scenario. The shared "clean up any leftover" step can't be used here
  # (it expects search to filter as you type), so if a run fails midway a
  # stray "qa-..." list can be left behind and is safe to delete by hand.
  Scenario: Creating a list from My Lists, finding it with search, and deleting it
    Given I am navigating the page as a "logged in" user
    And I am on the "account-wishlist" page
    And I wait for the page to settle
    When I click on the "Create a new Wishlist" element
    And I fill in the "New list name input" input field with a unique value, remembering it as "list name"
    And I click on the "Create list submit" button
    Then I should be redirected to the "account-wishlist-detail" page
    And the "Wishlist title" should contain the remembered "list name"

    When I am on the "account-wishlist" page
    And I wait for the page to settle
    And I fill in the "search bar" input field with the remembered "list name"
    And I click on the "Search button" button
    Then I should see "1" "Wishlist rows" displayed
    And the remembered "list name" should appear in the "Wishlist rows" element

    When I delete the row containing the remembered "list name" from the "Wishlist rows" table
    And I reload the page
    And I wait for the page to settle
    Then the remembered "list name" should not appear in the "Wishlists table" element
