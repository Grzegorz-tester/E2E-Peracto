@regression
Feature: Test Harness - Get Prices

  # Bespoke to MIPA - see test-harness-get-product.feature for why the
  # whole Test Harnesses section lives in its own project-specific path
  # rather than the shared Carbon_admin folder.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): like Get Product,
  # this is a real live call to MIPA's Business Central ERP (customer-
  # specific pricing), not a Peracto-side lookup - it builds a request
  # payload from Customer Number + a comma-separated SKU list and renders
  # BC's raw JSON response under #response-details, echoing back the SKU
  # searched for alongside a real "Price" field. Read-only, safe to run
  # repeatedly.
  #
  # Leaving Customer Number empty and submitting produces no response
  # panel at all (silently no-ops rather than erroring) - a required
  # field, not an optional filter - confirmed live, hence hardcoding
  # "AAA01" below rather than treating it as optional. "AAA01" is the
  # real BC customer number tied to MIPA_ADMIN_ADMIN_EMAIL - confirmed via
  # Get Customer's own response for that same email.

  Scenario: Looking up a real product's price for a real customer returns its own ERP data
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I remember the text of the first "product SKU" matching the pattern "^\d+$" as "test harness sku"
    And I click precisely on the "Test Harnesses" element
    And I click precisely on the "Get Prices" element
    And I fill in the "Customer Number" input field with "AAA01"
    And I fill in the "SKUs" input field with the remembered "test harness sku"
    And I click precisely on the "Submit" element
    Then the "response details" should contain the remembered "test harness sku"
    And the "response details" should contain the text "Price"
