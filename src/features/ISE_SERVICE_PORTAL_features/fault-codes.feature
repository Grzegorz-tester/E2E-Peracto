@regression @creates-reference-data
Feature: Fault code management

  # ISE-SP.17: add, edit and hide (never delete) fault codes. Codes can't be
  # deleted, so every run leaves "VT <timestamp>" / "Velstar Test" codes
  # behind, most of them hidden (inactive).
  #
  # CONFIRMED live (2026-10-06), differs from SoW:
  # - There's no screen to manage complaint codes (/complaint-codes and
  #   /complaints are 404, nothing in Settings), although Diagnosis offers a
  #   complaint code list. SP.17 covers both lists.
  # - Admin can manage fault codes too. The SoW puts this in the Owner-only
  #   Settings area.

  Background:
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/fault-codes"
    And I click on the "New fault code" link
    Then I should be redirected to the "fault-code-new" page
    When I fill in the "Fault code" input field with a unique value starting with "VT", remembering it as "fault code"
    And I fill in the "Label" input field with "Velstar Test fault"
    And I ensure the "Active" checkbox is checked
    And I click on the "Save fault code" button
    Then I should be redirected to the "fault-codes" page

  Scenario: The Owner adds a fault code and it's listed as active
    When I fill in the "Search fault codes" input field with the remembered "fault code"
    And I press Enter in the "Search fault codes" input field
    Then the current URL should contain "q="
    And the "first record title" should contain the remembered "fault code"
    And the "first record title" should contain the text "Velstar Test fault"
    And the "first record title" should contain the text "Active"

  Scenario: The Owner edits a fault code and hides it
    When I fill in the "Search fault codes" input field with the remembered "fault code"
    And I press Enter in the "Search fault codes" input field
    # Turbo changes the URL before the list re-renders; wait for the code
    # itself before clicking a row action.
    Then the "first record title" should contain the remembered "fault code"
    When I click on the "first record Edit" link
    Then I should be redirected to the "fault-code-edit" page
    When I fill in the "Label" input field with "Velstar Test fault (edited)"
    And I uncheck the "Active"
    And I click on the "Save fault code" button
    Then I should be redirected to the "fault-codes" page
    When I navigate directly to the path "/fault-codes?filter=inactive"
    And I fill in the "Search fault codes" input field with the remembered "fault code"
    And I press Enter in the "Search fault codes" input field
    Then the current URL should contain "q="
    And the "first record title" should contain the remembered "fault code"
    And the "first record title" should contain the text "Velstar Test fault (edited)"
    And the "first record title" should contain the text "Inactive"

  Scenario: Only active fault codes are offered at Diagnosis
    # A hidden code must stop being offered, while staying on historic jobs.
    When I fill in the "Search fault codes" input field with the remembered "fault code"
    And I press Enter in the "Search fault codes" input field
    # Turbo changes the URL before the list re-renders; wait for the code
    # itself before clicking a row action.
    Then the "first record title" should contain the remembered "fault code"
    When I click on the "first record Edit" link
    Then I should be redirected to the "fault-code-edit" page
    When I uncheck the "Active"
    And I click on the "Save fault code" button
    Then I should be redirected to the "fault-codes" page
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "engineer" user
    And I click on the "New job" link
    Then I should be redirected to the "job-new" page
    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with "1 Velstar Test Street"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Next" button
    And I fill in the "PO number" input field with a unique code
    And I click on the "Warranty Service option" element
    And I click on the "Inside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-diagnosis" page
    And the "Fault code" should not contain the remembered "fault code"
    And the "Fault code" should contain the text "F-134 - Wiring fault"
