@regression
Feature: Account wishlists

  # /account/wishlists is admin-account-only - the "logged in" test account
  # gets no "Wishlists" sidebar link and a genuine 404 on this URL even
  # while logged in. The "wishlist admin" user type is a distinct account
  # with wishlist access (see RUSSELLS_WISHLIST_ADMIN_EMAIL/PASSWORD in
  # .env.example) - not the separate RUSSELLS_ADMIN_ADMIN pair, which logs
  # into the Peracto Admin *site*, a different project entirely.
  #
  # Every wishlist this suite creates is named "Playwright QA ..." so the
  # cleanup step can never touch anything else in the account - it refuses
  # to delete any row whose name doesn't contain that prefix.
  #
  # This account's wishlist list is real, shared, persistent backend state -
  # both scenarios below mutate it, so they must never run concurrently
  # against each other. Russells' own env config runs a single worker
  # (PARALLEL=1), which already guarantees that.

  Scenario: Non-admin user has no Wishlists link and gets a 404
    Given I am navigating the page as a "logged in" user
    And I click on the "Accept cookies" button if present
    Then I should see "0" "Wishlists" displayed
    When I navigate directly to the path "/account/wishlists"
    Then a heading with the text "We couldn't find the page you're looking for" should be displayed

  @smoke
  Scenario: Admin can create, search, sort and delete a wishlist from the list
    Given I am navigating the page as a "wishlist admin" user
    And I click on the "Accept cookies" button if present
    And I am on the "account-wishlists" page
    And I clean up any leftover "Playwright QA" wishlists

    When I click on the "Create Wishlist" button
    Then the "Create Wishlist submit" should not be enabled
    When I fill in the "Wishlist name input" input field with a unique value, remembering it as "wishlist name a"
    Then the "Create Wishlist submit" should be enabled
    When I click on the "Create Wishlist submit" button
    Then I should be redirected to the "account-wishlist-detail" page
    And the "Wishlist name" should contain the remembered "wishlist name a"

    When I am on the "account-wishlists" page
    And I click on the "Create Wishlist" button
    And I fill in the "Wishlist name input" input field with a unique value, remembering it as "wishlist name b"
    And I click on the "Create Wishlist submit" button
    Then I should be redirected to the "account-wishlist-detail" page

    When I am on the "account-wishlists" page
    Then clicking the "Wishlist name sort button" button twice should reverse the "Wishlist rows" row order

    When I fill in the "Wishlist search input" input field with the remembered "wishlist name a"
    Then I should see "1" "Wishlist rows" displayed
    And the remembered "wishlist name a" should appear in the "Wishlist rows" element

    When I delete the row containing the remembered "wishlist name a" from the "Wishlist rows" table
    And I fill in the "Wishlist search input" input field with the remembered "wishlist name b"
    And I delete the row containing the remembered "wishlist name b" from the "Wishlist rows" table

  Scenario: Admin can add, update quantity, remove an item and rename a wishlist
    Given I am navigating the page as a "wishlist admin" user
    And I click on the "Accept cookies" button if present
    And I am on the "account-wishlists" page
    And I clean up any leftover "Playwright QA" wishlists

    When I click on the "Create Wishlist" button
    And I fill in the "Wishlist name input" input field with a unique value, remembering it as "wishlist name"
    And I click on the "Create Wishlist submit" button
    Then I should be redirected to the "account-wishlist-detail" page
    And the "Wishlist no items text" should be displayed

    When I fill in the "Search bar" input field with "bearing"
    And I click on the "1st" "Quick Buy result link" element
    Then the "quantity input" should equal the value "1"

    When I increment the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "2"

    When I click on the "Remove" button
    Then the "Wishlist no items text" should be displayed

    When I click on the "Edit wishlist name" button
    And I fill in the "Wishlist name input" input field with a unique value, remembering it as "renamed wishlist name"
    And I click on the "Save wishlist name" button
    Then the "Wishlist name" should contain the remembered "renamed wishlist name"

    When I click on the "Edit wishlist name" button
    And I fill in the "Wishlist name input" input field with a unique value, remembering it as "discarded wishlist name"
    And I click on the "Cancel wishlist name" button
    Then the "Wishlist name" should not contain the remembered "discarded wishlist name"
    And the "Wishlist name" should contain the remembered "renamed wishlist name"

    When I click on the "Share Wishlist" button
    Then the "Share dialog proceed" should not be enabled
    When I fill in the "Share email input" input field with "velstar.qa.wishlist.share@velstar.co.uk"
    Then the "Share dialog proceed" should be enabled
    When I click on the "Share dialog close" button
    Then the "Share email input" should not be displayed

    When I click on the "Delete wishlist" button
    And I click on the "Confirm deletion proceed" button
    Then I should be redirected to the "account-wishlists" page
