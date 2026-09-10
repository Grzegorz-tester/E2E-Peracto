@regression
Feature: Test Harness - Get Account Balance

  # Bespoke to MIPA - see test-harness-get-product.feature for why the
  # whole Test Harnesses section lives in its own project-specific path
  # rather than the shared Carbon_admin folder.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): a real live call to
  # MIPA's Business Central ERP by customer email alone (Account Number
  # can be left blank - confirmed live it still resolves the right
  # customer), rendering BC's raw JSON response (a "customerBalances"
  # odata payload with creditLimit/balance/balanceDue) under
  # #response-details. Unlike Get Invoices/Get Customer, this response
  # doesn't echo the customer number itself - "systemID" is the closest
  # thing to a stable per-customer identifier it contains, but it's an
  # opaque BC GUID not worth asserting on directly, so this instead
  # confirms the real odata schema for this specific endpoint
  # ("customerBalances") and a genuine "creditLimit" field came back,
  # rather than an error or empty stub. Read-only, safe to run repeatedly.

  Scenario: Looking up account balance for a real customer returns their own ERP data
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Test Harnesses" element
    And I click precisely on the "Get Account Balance" element
    And I fill in the "User Email" input field with the "admin" user's email
    And I click precisely on the "Submit" element
    Then the "response details" should contain the text "customerBalances"
    And the "response details" should contain the text "creditLimit"
