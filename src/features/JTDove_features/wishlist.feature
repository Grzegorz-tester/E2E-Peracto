@regression
Feature: Wishlists (My Lists)

  # New coverage (2026-10-05). The shared test account already holds
  # "Velstar Test Wishlist" (id 26) and someone else's "Greg new wishlist" -
  # leave both alone. Every list these scenarios create is named with a
  # unique "qa-" value and deleted at the end; "I clean up any leftover"
  # sweeps any that an earlier failed run left behind.

  Background:
    Given I am navigating the page as a "logged in" user


  Scenario: A wishlist can be created and deleted from My Lists
    Given I am on the "account-wishlist" page
    And I wait for the page to settle
    And I clean up any leftover "qa-" wishlists
    When I click on the "Create a new Wishlist" element
    And I fill in the "new wishlist name input" input field with a unique value starting with "qa-", remembering it as "list name"
    And I click on the "Create wishlist submit" button
    # The list IS created (toast + table refresh) but the dialog stays open
    # afterwards (confirmed live 2026-10-06), so close it before filtering.
    Then the "wishlist created toast" should be displayed
    When I press the Escape key
    And I reload the page
    And I wait for the page to settle
    And I fill in the "Wishlist search input" input field with the remembered "list name"
    And I wait for the search results to update
    Then the "Wishlist names" should contain the remembered "list name"
    When I delete the row containing the remembered "list name" from the "Wishlist rows" table
    And I fill in the "Wishlist search input" input field with the remembered "list name"
    And I wait for the search results to update
    Then the "Wishlist names" should not contain the remembered "list name"


  Scenario: A product can be saved to a new wishlist from the PDP
    Given I am on the "account-wishlist" page
    And I wait for the page to settle
    And I clean up any leftover "qa-" wishlists
    When I am on the "test-product" page
    And I wait for the page to settle
    And I click on the "Add to list" button
    Then the "add to wishlist modal" should be displayed
    When I click on the "Create a new wishlist link" element
    And I fill in the "PDP new wishlist name input" input field with a unique value starting with "qa-", remembering it as "list name"
    And I click on the "PDP create wishlist submit" button
    And I wait for the save to complete
    When I am on the "account-wishlist" page
    And I wait for the page to settle
    And I fill in the "Wishlist search input" input field with the remembered "list name"
    And I wait for the search results to update
    Then the "Wishlist names" should contain the remembered "list name"
    When I click on the "first wishlist edit link" element, retrying until redirected to the "account-wishlist-detail" page
    Then the "Wishlist lines" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    When I am on the "account-wishlist" page
    And I wait for the page to settle
    And I fill in the "Wishlist search input" input field with the remembered "list name"
    And I wait for the search results to update
    And I delete the row containing the remembered "list name" from the "Wishlist rows" table


  Scenario: An existing wishlist's page lists its products
    Given I navigate directly to the path "/account/wishlists/26"
    And I wait for the page to settle
    Then the "Wishlist lines" should be displayed
    And the "ADD WISHLIST TO BASKET" should be displayed
