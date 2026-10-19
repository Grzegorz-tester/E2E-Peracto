@regression
Feature: Account actions

  # Built 2026-09-30 from a live inspection of staging. my-account.feature
  # checks each tab loads; this covers what a customer actually does there.
  #
  # The logged-in test account is SHARED with other people: it already
  # holds their addresses ("Bob Johnsons", "Fred Smith") and 15 of their
  # moodboards. Every scenario here only creates, changes and removes its
  # OWN uniquely named data, and puts anything it edits back.
  #
  # Profile and address book edits are the test user's own account data, so
  # they're safe on production too (CLAUDE.md). Moodboard create/delete is
  # also the user's own data, but is kept to staging (@not-on-production) to
  # avoid leaving test boards on the live account if a run fails midway.
  #
  # The Moodboards list shows only the 15 newest boards, with no pagination
  # (confirmed live 2026-09-30: 3 test boards pushed 3 older ones out of view
  # until they were deleted). A new board always appears, as it's the newest.

  Background:
    Given I am navigating the page as a "logged in" user
    And I click on the "Allow all cookies" button if present


  Scenario: Saving the profile's contact number persists after a reload, and can be restored
    When I am on the "account-profile" page
    And I remember the value of the "Contact number" input field as "original contact number"
    And I fill in the "Contact number" input field with a unique UK mobile number, remembering it as "new contact number"
    And I click on the "Save Changes" button
    Then the "profile alert" should contain the text "User successfully updated"
    When I reload the page
    Then the "Contact number" input field should have the remembered "new contact number"
    When I fill in the "Contact number" input field with the remembered "original contact number"
    And I click on the "Save Changes" button
    Then the "profile alert" should contain the text "User successfully updated"
    When I reload the page
    Then the "Contact number" input field should have the remembered "original contact number"


  Scenario: Adding, editing and removing a delivery address
    When I am on the "account-address-book" page
    # Settle first: straight after load, "Add new address" can be clicked
    # before it's hydrated and does nothing (confirmed on production,
    # 2026-09-30 - the step then times out waiting for the form).
    And I wait for the page to settle
    And I add a new delivery address with the following details:
      | First name     | Velstar           |
      | Last name      | Test              |
      | Address line 1 | 221B Baker Street |
      | City           | London            |
      | Postcode       | NW1 6XE           |
    And I edit the last added delivery address with the following details:
      | First name     | Velstar     |
      | Last name      | Test Edited |
      | Address line 1 | 1 Deansgate |
      | City           | Manchester  |
      | Postcode       | M1 1AE      |
    And I remove the last added delivery address


  Scenario: Adding, editing and removing a billing address
    When I am on the "account-address-book" page
    # Settle first: straight after load, "Add new address" can be clicked
    # before it's hydrated and does nothing (confirmed on production,
    # 2026-09-30 - the step then times out waiting for the form).
    And I wait for the page to settle
    And I add a new billing address with the following details:
      | First name     | Velstar           |
      | Last name      | Test              |
      | Address line 1 | 221B Baker Street |
      | City           | London            |
      | Postcode       | NW1 6XE           |
    And I edit the last added billing address with the following details:
      | First name     | Velstar     |
      | Last name      | Test Edited |
      | Address line 1 | 1 Deansgate |
      | City           | Manchester  |
      | Postcode       | M1 1AE      |
    And I remove the last added billing address


  # The shared test account has 4 orders on staging but none on production
  # (confirmed 2026-09-30), and orders are never placed on production.
  @requires-order-history
  Scenario: Filtering order history by order number, then opening that order
    When I am on the "account-orders" page
    And I remember the text of "first order reference" as "order number"
    And I fill in the "orders reference filter" input field with the remembered "order number"
    Then the "first order reference" text should equal the remembered "order number"
    When I click on the "first order row" element
    Then I should eventually be redirected to the "account-order-detail" page
    And the "order detail reference" should contain the remembered "order number"
    And the "order delivery address" should be displayed
    And the "order product card" should be displayed


  # Moodboard (quote) create/edit/delete coverage lives in
  # moodboards-and-quotes.feature.


  Scenario: Signing out logs the user out and protects the account pages
    When I am on the "account" page
    And I click on the "Sign Out button" link
    Then the "Sign In button" should be displayed
    # Direct navigation, not "I am on the account page": that step waits to
    # land on /account, and a signed-out user is (correctly) sent to /login.
    When I navigate directly to the path "/account"
    Then I should eventually be redirected to the "login" page
