@regression
Feature: Test Harness - Get Customer

  # Bespoke to MIPA - see test-harness-get-product.feature for why the
  # whole Test Harnesses section lives in its own project-specific path
  # rather than the shared Carbon_admin folder.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): a real live call to
  # MIPA's Business Central ERP by customer email, rendering BC's raw
  # JSON response (a "customers" odata payload) under #response-details -
  # confirmed it echoes back "customerno": "AAA01", the real BC customer
  # number tied to MIPA_ADMIN_ADMIN_EMAIL. Read-only, safe to run
  # repeatedly.

  Scenario: Looking up a real customer by email returns their own ERP data
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Test Harnesses" element
    And I click precisely on the "Get Customer" element
    And I fill in the "User Email" input field with the "admin" user's email
    And I click precisely on the "Submit" element
    Then the "response details" should contain the text "AAA01"
