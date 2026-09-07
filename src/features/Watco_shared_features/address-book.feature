@regression
Feature: Address book

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. Country is chosen by the "2nd" real dropdown option
  # (index 1 - skipping the blank placeholder at index 0), not a literal
  # country name, so this works regardless of which country list/locale a
  # market's own site shows - confirmed live that the form doesn't
  # validate the postcode format against whichever country ends up
  # selected. Every step scopes to the ONE address card containing this
  # scenario's own "Velstar Test Automation Address" marker (see
  # address-book-list.json), so it can never touch the account's
  # pre-existing default delivery/billing addresses that other checkout
  # scenarios rely on already being populated - and it always deletes what
  # it added, leaving the shared account's address book exactly as it
  # found it.

  Scenario: Adding, editing and deleting an address all work and clean up after themselves
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page

    When I am on the "address-book-list" page
    And I click on the "Add new address link" link
    Then I should be redirected to the "address-book-new" page

    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address telephone" input field with "07700900123"
    And I fill in the "address line 1" input field with "Velstar Test Automation Address"
    And I fill in the "address line 2" input field with "Velstar Test Automation Address"
    And I fill in the "address city" input field with "Test City"
    And I fill in the "address postcode" input field with "12345"
    And I select the "2nd" option from the "address country" dropdown
    And I click on the "Save address" button
    Then I should be redirected to the "address-book-list" page
    And the "test address card" should be displayed

    When I click on the "edit link for test address" link
    Then I should be redirected to the "address-book-edit" page
    And I fill in the "address city" input field with "Updated Test City"
    And I click on the "Save address" button
    Then I should be redirected to the "address-book-list" page

    When I click on the "delete button for test address" element, accepting the confirmation dialog
    Then the "test address card" should not be displayed
