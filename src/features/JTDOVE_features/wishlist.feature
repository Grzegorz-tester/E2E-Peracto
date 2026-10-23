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
    # Since 2026-10-22 creating a list redirects straight to its own page
    # (no toast); before that the dialog stayed open with a toast.
    Then I should eventually be redirected to the "account-wishlist-detail" page
    When I am on the "account-wishlist" page
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


  # Manual regression cases 158-174 (added 2026-10-22). Everything below
  # works on throwaway "qa-" lists, apart from "Add wishlist to basket",
  # which only reads the "Velstar Test Wishlist" fixture (id 26).
  Scenario: Creating a wishlist needs a name
    Given I am on the "account-wishlist" page
    And I wait for the page to settle
    When I click on the "Create a new Wishlist" element
    Then the "new wishlist dialog" should be displayed
    And the "Create wishlist submit" should not be enabled
    When I fill in the "new wishlist name input" input field with "qa-never-created"
    Then the "Create wishlist submit" should be enabled
    When I click on the "Close wishlist dialog" button
    Then the "new wishlist dialog" should not be displayed


  Scenario: Wishlists can be searched by name and the search reset
    Given I am on the "account-wishlist" page
    And I wait for the page to settle
    When I fill in the "Wishlist search input" input field with "Velstar Test"
    And I wait for the search results to update
    Then the "Wishlist names" should contain the text "Velstar Test Wishlist"
    And the "Wishlist names" should not contain the text "Greg new wishlist"
    When I click on the "Reset filters" button
    Then the "wishlist table" should contain the text "Greg new wishlist"


  # Quick Add (manual case 168) isn't automated: its suggestions are plain
  # product links that open the PDP rather than adding to the list
  # (confirmed live 2026-10-22). Awaiting QA on whether that's intended.
  Scenario: A wishlist's lines can be updated and removed
    Given I am on the "account-wishlist" page
    And I wait for the page to settle
    And I clean up any leftover "qa-" wishlists
    When I am on the "test-product" page
    And I wait for the page to settle
    And I click on the "Add to list" button
    And I click on the "Create a new wishlist link" element
    And I fill in the "PDP new wishlist name input" input field with a unique value starting with "qa-", remembering it as "list name"
    And I click on the "PDP create wishlist submit" button
    And I wait for the save to complete
    And I am on the "account-wishlist" page
    And I wait for the page to settle
    And I fill in the "Wishlist search input" input field with the remembered "list name"
    And I wait for the search results to update
    And I click on the "first wishlist edit link" element, retrying until redirected to the "account-wishlist-detail" page
    And I wait for the page to settle
    Then the "breadcrumb" should contain the remembered "list name"
    And the "quick add" should be displayed
    And the "wishlist total panel" should be displayed
    And the "ADD WISHLIST TO BASKET" should be displayed
    And the "Wishlist lines" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    # Quantity update
    When I remember the text of "first line total" as "line total"
    And I click precisely on the "first line increment" element
    And I click on the "first line Update" button
    And I wait for the save to complete
    Then the "first line quantity" should equal the value "2"
    And the "first line total" text should not equal the remembered "line total"
    # Remove a line
    When I click on the "first line Remove" button
    And I wait for the save to complete
    Then the "empty wishlist message" should be displayed
    # Delete from the details page
    When I click on the "Delete Wishlist" button
    Then the "delete wishlist dialog" should be displayed
    When I click on the "Confirm delete wishlist" button
    Then I should eventually be redirected to the "account-wishlist" page
    When I fill in the "Wishlist search input" input field with the remembered "list name"
    And I wait for the search results to update
    Then the "Wishlist names" should not contain the remembered "list name"


  Scenario: A wishlist can be renamed and its share form validates the email
    Given I am on the "account-wishlist" page
    And I wait for the page to settle
    And I clean up any leftover "qa-" wishlists
    When I click on the "Create a new Wishlist" element
    And I fill in the "new wishlist name input" input field with a unique value starting with "qa-", remembering it as "list name"
    And I click on the "Create wishlist submit" button
    Then I should eventually be redirected to the "account-wishlist-detail" page
    And I wait for the page to settle
    # Rename
    When I click on the "Edit Name" button
    Then the "edit name dialog" should be displayed
    When I fill in the "edit name input" input field with a unique value starting with "qa-", remembering it as "new list name"
    And I click on the "Save name" button
    And I wait for the save to complete
    # The page keeps showing the old name until it's reloaded.
    Then I reload the page until the "breadcrumb" contains the remembered "new list name", for up to 30 seconds
    # Share: no email is sent, only the validation is checked
    When I click on the "Share" button
    Then the "share dialog" should be displayed
    When I click on the "Share submit" button
    Then the "share dialog" should be displayed
    When I fill in the "share email input" input field with "not_an_email@"
    And I click on the "Share submit" button
    Then the "share dialog" should be displayed
    And the "success toast" should not appear within "5" seconds
    When I click on the "share dialog close" button
    Then the "share dialog" should not be displayed
    # Clean up
    When I click on the "Delete Wishlist" button
    And I click on the "Confirm delete wishlist" button
    Then I should eventually be redirected to the "account-wishlist" page
    When I fill in the "Wishlist search input" input field with the remembered "new list name"
    And I wait for the search results to update
    Then the "Wishlist names" should not contain the remembered "new list name"


  Scenario: A wishlist can be added to the basket
    Given I navigate directly to the path "/account/wishlists/26"
    And I wait for the page to settle
    And I remember the text of "first line name" as "wishlist product"
    When I click on the "ADD WISHLIST TO BASKET" button
    Then I should eventually be redirected to the "basket" page
    And I wait for the page to settle
    Then the "basket lines" should contain the remembered "wishlist product"
    # The basket belongs to the browser session, not the account (a fresh
    # login always starts empty, confirmed live 2026-10-22), so the
    # wishlist's line is the only one here.
    When I click on the "Remove item" button
    Then the "no items message" should be displayed
