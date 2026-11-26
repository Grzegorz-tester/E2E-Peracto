@regression
Feature: Wishlists (My Lists) pagination and limits

  # Manual regression cases 151, 157 and 175 (added 2026-11-18). Runs as the
  # "credit" user (staging user 73), not the shared account: wishlists are
  # per user, and the shared account's list page only shows 3 of its 24 lists
  # (and its wishlist 18 500s in the API), so it can't be used for paging.
  #
  # Fixtures (created 2026-11-18 via the storefront API, DO NOT DELETE): user
  # 73 holds exactly 20 lists, "Velstar Test Pagination 01".."20" (ids
  # 217-236). Confirmed live: My Lists shows 15 per page ("1 of 2"), and the
  # API refuses a 21st list ("maximum Wishlists for User has been reached"),
  # so 20 is both the page-2 fixture and the per-user cap.
  #
  # Pagination is two chevron buttons around an "N of M" label, no testids.

  Background:
    Given I am navigating the page as a "credit" user
    And I am on the "account-wishlist" page
    And I wait for the page to settle


  Scenario: My Lists pages through the lists 15 at a time
    Then the "wishlist pagination indicator" should contain the text "1 of 2"
    And I should see "15" "Wishlist rows" displayed
    And the "wishlist pagination previous" should not be enabled
    And the "wishlist pagination next" should be enabled
    When I click on the "wishlist pagination next" button
    Then the "wishlist pagination indicator" should contain the text "2 of 2"
    And I should see "5" "Wishlist rows" displayed
    And the "wishlist pagination next" should not be enabled
    And the "wishlist pagination previous" should be enabled
    When I click on the "wishlist pagination previous" button
    Then the "wishlist pagination indicator" should contain the text "1 of 2"
    And I should see "15" "Wishlist rows" displayed


  Scenario: Searching narrows the paged list and resetting restores it
    When I fill in the "Wishlist search input" input field with "Pagination 07"
    Then I should see "1" "Wishlist rows" displayed
    And the "Wishlist names" should contain the text "Velstar Test Pagination 07"
    When I click on the "Reset filters" button
    Then I should see "15" "Wishlist rows" displayed
    And the "wishlist pagination indicator" should contain the text "1 of 2"


  Scenario: My Lists shows each list's name, dates and actions
    Then the "wishlist header row" should contain the text "Wishlist Name"
    And the "wishlist header row" should contain the text "Created At"
    And the "wishlist header row" should contain the text "Last Modified"
    And the "wishlist header row" should contain the text "Edit"
    And the "wishlist header row" should contain the text "Delete"
    And the "Wishlist names" should contain the text "Velstar Test Pagination"
    # The remember steps fail unless the text matches, so they assert the
    # dd/mm/yyyy date format.
    And I remember the part of the "first wishlist created date" text matching the pattern "^\d{2}/\d{2}/\d{4}$" as "created date"
    And I remember the part of the "first wishlist modified date" text matching the pattern "^\d{2}/\d{2}/\d{4}$" as "modified date"
    And the "first wishlist edit link" should be displayed
    And the "first wishlist delete action" should contain the text "Delete Wishlist"
