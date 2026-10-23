@regression
Feature: Account actions

  # New coverage (2026-10-05). These change the shared test account's own
  # storefront data (allowed on staging and production per CLAUDE.md), and
  # put everything back.

  Background:
    Given I am navigating the page as a "logged in" user


  # The profile page keeps serving the pre-save value for a while after a
  # successful save (confirmed live 2026-10-07), so persistence is checked
  # by reloading until it shows up rather than with a single reload.
  Scenario: Saving the profile keeps the customer's details
    Given I am on the "account-profile" page
    And I wait for the page to settle
    And I remember the value of the "profile contact number" input field as "original number"
    When I fill in the "profile contact number" input field with a unique UK mobile number, remembering it as "new number"
    And I click on the "Save changes" button
    And I wait for the save to complete
    Then I reload the page until the "profile contact number" contains the remembered "new number", for up to 60 seconds
    And I wait for the page to settle
    When I fill in the "profile contact number" input field with the remembered "original number"
    And I click on the "Save changes" button
    And I wait for the save to complete
    Then I reload the page until the "profile contact number" contains the remembered "original number", for up to 60 seconds


  Scenario: A new delivery address can be added and deleted
    Given I am on the "account-address-book" page
    And I wait for the page to settle
    And I remember the number of "delivery address cards" elements as "address count"
    When I click on the "Add delivery address" button
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with a unique value, remembering it as "last name"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Save address" button
    And I wait for the save to complete
    Then the "delivery addresses" should contain the remembered "last name"
    And the number of "delivery address cards" elements should be more than the remembered "address count"
    When I click on the "Delete address" inside the "delivery address cards" containing the remembered "last name"
    And I click on the "Confirm deletion proceed" button
    And I wait for the save to complete
    Then the "delivery addresses" should not contain the remembered "last name"


  # Manual regression case 143 (added 2026-10-22).
  Scenario: An existing delivery address can be edited
    Given I am on the "account-address-book" page
    And I wait for the page to settle
    When I click on the "Add delivery address" button
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with a unique value, remembering it as "last name"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Save address" button
    And I wait for the save to complete
    Then the "delivery addresses" should contain the remembered "last name"
    When I click on the "Edit address" inside the "delivery address cards" containing the remembered "last name"
    And I wait for the page to settle
    And I fill in the "address last name" input field with a unique value, remembering it as "edited last name"
    And I click on the "Save address" button
    And I wait for the save to complete
    Then the "delivery addresses" should contain the remembered "edited last name"
    And the "delivery addresses" should not contain the remembered "last name"
    When I click on the "Delete address" inside the "delivery address cards" containing the remembered "edited last name"
    And I click on the "Confirm deletion proceed" button
    And I wait for the save to complete
    Then the "delivery addresses" should not contain the remembered "edited last name"


  # Smoke case 204 (added 2026-10-23). "Reset Password" on the profile opens
  # an in-page Change Password form rather than emailing a link (confirmed
  # live 2026-10-23). The password is never changed: the shared account
  # must keep its current one.
  Scenario: Reset Password on the profile opens the change password form
    Given I am on the "account-profile" page
    And I wait for the page to settle
    When I click on the "profile Reset Password" button
    Then the "change password heading" should be displayed
    And the "existing password" should be displayed
    When I click on the "Back to User Form" element
    Then the "profile first name" should be displayed
