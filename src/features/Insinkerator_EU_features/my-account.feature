@regression
Feature: My account

  # Ported from P3Playwright's insinkerator_eu/tests/account/{change-password,
  # account-address-book,orders}.test.ts. accountTestUser_1 ("logged in" user
  # type here) is a SHARED staging account used by every logged-in scenario
  # in this project - the change-password scenario deliberately changes the
  # password to itself (new value == existing value) so it exercises the
  # real form-submission and success path without ever leaving the shared
  # account on a different password than everyone else expects.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    And I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

  Scenario: User can submit the change-password form with the existing password, and it still works afterwards
    When I am on the "account-profile" page
    And I click on the "Reset Password" element
    And I fill in the "Existing Password" input field with the "logged in" user's password
    And I fill in the "New Password" input field with the "logged in" user's password
    And I fill in the "Repeat New Password" input field with the "logged in" user's password
    And I click on the "Save Changes" button
    Then the "change password alert" should contain the text "Password successfully updated"

    When I click on the "Sign Out" element
    Then the "welcome message" should not be displayed

    When I am on the "login" page
    And I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

  Scenario: User can add, edit and remove a delivery address
    When I am on the "account-address-book" page
    And I add a new delivery address with the following details:
      | First name      | Jane          |
      | Last name       | Doe           |
      | Address line 1  | 221B Baker St |
      | City             | Lisbon        |
      | Postcode        | 1000-001      |
    And I edit the last added delivery address with the following details:
      | First name      | Janet         |
      | Last name       | Doeherty      |
      | Address line 1  | 10 Downing St |
      | City             | Porto         |
      | Postcode        | 4000-001      |
    And I remove the last added delivery address

  Scenario: User can add, edit and remove a billing address
    When I am on the "account-address-book" page
    And I add a new billing address with the following details:
      | First name      | John          |
      | Last name       | Smith         |
      | Address line 1  | 10 High St    |
      | City             | Faro          |
      | Postcode        | 8000-001      |
    And I edit the last added billing address with the following details:
      | First name      | Jonathan      |
      | Last name       | Smithson      |
      | Address line 1  | 5 Market Sq   |
      | City             | Braga         |
      | Postcode        | 4700-001      |
    And I remove the last added billing address

  Scenario: User can view a real order in the Orders page
    When I am on the "account-orders" page
    Then the "orders header row" should contain the text "Order Number"
    And the "orders header row" should contain the text "Placed On"
    And the "orders header row" should contain the text "Amount"
    And the "orders reference filter" should be displayed
    And the "orders date range picker" should be displayed
    And the "orders total amount filter" should be displayed
    And the "orders first row" should be displayed

    When I click on the "orders first row" element
    Then I should be redirected to the "account-order-detail" page
    And the "order reference" should be displayed
    And the "order confirmation email" should contain the "logged in" user's email
