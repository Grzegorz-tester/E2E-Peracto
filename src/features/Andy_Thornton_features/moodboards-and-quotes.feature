@regression @not-on-production
Feature: Moodboards and quotes

  # Built 2026-09-30 from a live exploration of staging. On Andy Thornton a
  # moodboard IS a quote: the PDP's pin icon opens an "Add to Quote" dialog
  # listing the user's moodboards, with "create a new quote" alongside, and
  # every board lives under My Account > Moodboards.
  #
  # The logged-in test account is SHARED with other people and already holds
  # their boards. Every board created here is named "Velstar Test Moodboard
  # <timestamp>", and the Background first deletes any leftover board with
  # that prefix (from an earlier run that failed midway), and nothing else.
  # Staging only: these write to the account.
  #
  # Confirmed live (2026-09-30):
  # - The list shows only the 15 newest boards, with no pagination.
  # - The PDP pin icon has no label, aria-label or testid (only a hidden
  #   "Add to Moodboard" heading while the dialog says "Add to Quote").
  # - The Add to Quote dialog pre-selects the newest board.
  # - Removing an item from a board has no confirmation; deleting a board
  #   (from the list or from the builder) asks Cancel/Delete.

  Background:
    Given I am navigating the page as a "logged in" user
    And I click on the "Allow all cookies" button if present
    When I am on the "account-moodboards" page
    And I delete every "moodboard rows" whose "moodboard name cell" starts with "Velstar Test Moodboard", using the "moodboard delete" and "confirm moodboard delete"


  Scenario: Creating a moodboard from My Account opens it empty, lists it, and it can be deleted from the list
    When I click on the "Create a new Moodboard" button
    And I fill in the "moodboard name input" input field with a unique value starting with "Velstar Test Moodboard", remembering it as "moodboard name"
    And I click on the "Create Moodboard" button
    Then I should eventually be redirected to the "account-moodboard-detail" page
    And the "moodboard title" should contain the remembered "moodboard name"
    And the "empty moodboard" should be displayed
    When I am on the "account-moodboards" page
    Then the "first moodboard name" should contain the remembered "moodboard name"
    When I click on the "moodboard delete" inside the "moodboard rows" containing the remembered "moodboard name"
    And I click on the "confirm moodboard delete" button
    And I wait for the page to settle
    And I reload the page
    Then the "moodboards table" should not contain the remembered "moodboard name"


  Scenario: Adding a product from the PDP puts it on the moodboard, and removing it empties the board again
    When I click on the "Create a new Moodboard" button
    And I fill in the "moodboard name input" input field with a unique value starting with "Velstar Test Moodboard", remembering it as "moodboard name"
    And I click on the "Create Moodboard" button
    Then I should eventually be redirected to the "account-moodboard-detail" page

    When I am on the "pdp" page
    And I wait for the page to settle
    And I click on the "Add to Quote icon" button
    Then the "add to quote dialog" should be displayed
    And the "selected quote" should contain the remembered "moodboard name"
    When I click on the "Add to Quote" button
    And I wait for the page to settle

    When I am on the "account-moodboards" page
    And I click on the "moodboard name cell" inside the "moodboard rows" containing the remembered "moodboard name"
    Then I should eventually be redirected to the "account-moodboard-detail" page
    And the "moodboard items" should contain the text "Vienna Stackable Side Chair"
    When I click on the "remove moodboard item" button
    And I wait for the page to settle
    And I reload the page
    Then the "empty moodboard" should be displayed
    And the "moodboard items" should not contain the text "Vienna Stackable Side Chair"
    When I am on the "account-moodboards" page
    And I delete every "moodboard rows" whose "moodboard name cell" starts with "Velstar Test Moodboard", using the "moodboard delete" and "confirm moodboard delete"
    Then the "moodboards table" should not contain the text "Velstar Test Moodboard"


  Scenario: Creating a new quote from the PDP saves it with the product on it
    When I am on the "pdp" page
    And I wait for the page to settle
    And I click on the "Add to Quote icon" button
    And I click on the "create a new quote" button
    Then the "CREATE quote" should have attribute "style" containing "not-allowed"
    When I fill in the "new quote name" input field with a unique value starting with "Velstar Test Moodboard", remembering it as "moodboard name"
    Then the "CREATE quote" should have attribute "style" containing "not-allowed"
    When I fill in the "new quote customer name" input field with "Velstar Test"
    And I fill in the "new quote reference" input field with "VELSTAR-TEST"
    Then the "CREATE quote" should have attribute "style" containing "pointer"
    When I click on the "CREATE quote" button
    And I wait for the page to settle

    When I am on the "account-moodboards" page
    Then the "moodboards table" should contain the remembered "moodboard name"
    When I click on the "moodboard name cell" inside the "moodboard rows" containing the remembered "moodboard name"
    Then I should eventually be redirected to the "account-moodboard-detail" page
    And the "moodboard items" should contain the text "Vienna Stackable Side Chair"
    When I am on the "account-moodboards" page
    And I delete every "moodboard rows" whose "moodboard name cell" starts with "Velstar Test Moodboard", using the "moodboard delete" and "confirm moodboard delete"
    Then the "moodboards table" should not contain the text "Velstar Test Moodboard"


  Scenario: Renaming a moodboard with Edit Moodboard persists after a reload
    When I click on the "Create a new Moodboard" button
    And I fill in the "moodboard name input" input field with a unique value starting with "Velstar Test Moodboard", remembering it as "moodboard name"
    And I click on the "Create Moodboard" button
    Then I should eventually be redirected to the "account-moodboard-detail" page
    When I click on the "moodboard actions" button
    And I click on the "Edit Moodboard" button
    And I fill in the "edit moodboard name" input field with a unique value starting with "Velstar Test Moodboard Renamed", remembering it as "new moodboard name"
    And I click on the "Save Changes" button
    And I wait for the page to settle
    And I reload the page
    Then the "moodboard title" should contain the remembered "new moodboard name"
    When I am on the "account-moodboards" page
    Then the "moodboards table" should contain the remembered "new moodboard name"
    And the "moodboards table" should not contain the remembered "moodboard name"
    When I am on the "account-moodboards" page
    And I delete every "moodboard rows" whose "moodboard name cell" starts with "Velstar Test Moodboard", using the "moodboard delete" and "confirm moodboard delete"
    Then the "moodboards table" should not contain the text "Velstar Test Moodboard"


  Scenario: Deleting a moodboard from inside the builder removes it
    When I click on the "Create a new Moodboard" button
    And I fill in the "moodboard name input" input field with a unique value starting with "Velstar Test Moodboard", remembering it as "moodboard name"
    And I click on the "Create Moodboard" button
    Then I should eventually be redirected to the "account-moodboard-detail" page
    When I click on the "moodboard actions" button
    And I click on the "Delete Moodboard" button
    And I click on the "confirm moodboard delete" button
    Then I should eventually be redirected to the "account-moodboards" page
    And the "moodboards table" should not contain the remembered "moodboard name"
