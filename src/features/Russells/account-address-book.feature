@regression
Feature: Account address book

  # accountTestUser_1 has a permanent fixture delivery + billing address (so
  # checkout always has a saved address to select) - each scenario here
  # adds ONE more address on top of that fixture, edits it, then removes
  # it, leaving the permanent fixture untouched.

  Background:
    Given I am navigating the page as a "logged in" user
    And I click on the "Accept cookies" button if present
    And I navigate directly to the path "/account/address-book"

  @smoke
  Scenario: User can add, edit and remove a delivery address
    When I add a new delivery address with the following details:
      | First name     | Jamie             |
      | Last name      | Playwright        |
      | Address line 1 | 221B Baker Street |
      | City           | London            |
      | Postcode       | NW1 6XE           |
    And I edit the last added delivery address with the following details:
      | First name     | Jamie          |
      | Last name      | Edited         |
      | Address line 1 | 1 Deansgate    |
      | City           | Manchester     |
      | Postcode       | M1 1AE         |
    And I remove the last added delivery address

  Scenario: User can add, edit and remove a billing address
    When I add a new billing address with the following details:
      | First name     | Jamie             |
      | Last name      | Playwright        |
      | Address line 1 | 221B Baker Street |
      | City           | London            |
      | Postcode       | NW1 6XE           |
    And I edit the last added billing address with the following details:
      | First name     | Jamie          |
      | Last name      | Edited         |
      | Address line 1 | 1 Deansgate    |
      | City           | Manchester     |
      | Postcode       | M1 1AE         |
    And I remove the last added billing address
