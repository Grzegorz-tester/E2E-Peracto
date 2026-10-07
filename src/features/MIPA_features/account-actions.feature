@regression
Feature: Account actions

  # Built 2026-10-01 from a live inspection of staging. my-account.feature
  # checks each tab loads; this covers what a customer actually does there.
  # Everything here only touches the test user's own account data and puts
  # back anything it changes.

  Background:
    Given I am navigating the page as a "logged in" user


  # Confirmed live: Save Changes sends PUT /users/<id> (200) but shows no
  # on-page success message, so the save is confirmed through that response
  # and then a reload.
  Scenario: Saving the profile's contact number persists after a reload, and can be restored
    When I am on the "account-profile" page
    And I wait for the page to settle
    And I remember the value of the "Contact number" input field as "original contact number"
    And I fill in the "Contact number" input field with a unique UK mobile number, remembering it as "new contact number"
    And I click on the "Save Changes" button and note the response status of a request to "/users/"
    Then the noted response status should equal 200
    When I reload the page
    And I wait for the page to settle
    Then the "Contact number" input field should have the remembered "new contact number"
    When I fill in the "Contact number" input field with the remembered "original contact number"
    And I click on the "Save Changes" button and note the response status of a request to "/users/"
    Then the noted response status should equal 200
    When I reload the page
    And I wait for the page to settle
    Then the "Contact number" input field should have the remembered "original contact number"


  # Confirmed live: all three checks below are client-side (no request is
  # sent), so a real password change is never attempted - that would lock
  # every other run out of this shared test account.
  Scenario: Change Password rejects empty and mismatched passwords
    When I am on the "account-profile" page
    And I wait for the page to settle
    And I click on the "Change Password" element
    Then the "Change password form" should be displayed
    When I click on the "Save Changes" button
    Then the "Change password form" should contain the text "Please enter your current password"
    And the "Change password form" should contain the text "Please enter your new password"
    When I fill in the "Current password" input field with "not-the-real-password"
    And I fill in the "New password" input field with "Velstar-Test-1!"
    And I fill in the "Repeat new password" input field with "Velstar-Test-2!"
    And I click on the "Save Changes" button
    Then the "Change password form" should contain the text "Passwords must match"
    When I click on the "Back to User Form" element
    Then the "First name" should be displayed


  # Customers can't add or edit addresses here (the page asks them to
  # contact MIPA), but they can pick their default delivery address
  # (PUT /addresses/<id>). Confirmed live 2026-10-01: before this scenario
  # existed the account had NO default delivery address; "Fred Smith"
  # (always 1st) is now the default and is what this scenario restores
  # every run. The 2nd address is one of the leftover "Velstar qa-..."
  # entries, which is fine to make default briefly. List order doesn't
  # change when the default changes.
  Scenario: Changing the default delivery address persists, and can be switched back
    When I am on the "account-address-book" page
    And I wait for the page to settle
    And I click on the "1st delivery address Make default" element if present
    And I wait for the page to settle
    Then the "1st delivery address" should contain the text "Default address"
    When I click on the "2nd delivery address Make default" element
    Then the "2nd delivery address" should contain the text "Default address"
    And the "1st delivery address" should contain the text "Make default"
    When I reload the page
    And I wait for the page to settle
    Then the "2nd delivery address" should contain the text "Default address"
    When I click on the "1st delivery address Make default" element
    Then the "1st delivery address" should contain the text "Default address"
    When I reload the page
    And I wait for the page to settle
    Then the "1st delivery address" should contain the text "Default address"
    And the "2nd delivery address" should contain the text "Make default"
