@regression
Feature: Test Harness - Send Order

  # Bespoke to MIPA - see test-harness-get-product.feature for why the
  # whole Test Harnesses section lives in its own project-specific path
  # rather than the shared Carbon_admin folder.
  #
  # Unlike the "Get ..." harnesses, this genuinely WRITES a real order
  # record into MIPA's Business Central ERP - confirmed live via its own
  # response echoing back "orderStatus": "Pending" and the submitted
  # order reference as "orderNo" (BC uppercases it - "qa-<timestamp>"
  # comes back as "QA-<timestamp>", hence the case-insensitive assertion
  # below, not a broken echo). Safe to run repeatedly specifically
  # because the form's own "Order Reference" field exists to let this be
  # resent under a different reference each time (its own on-page hint:
  # "This is used to override the order ID so the order can be sent more
  # than once if needed for testing.") - using the existing generic
  # "unique value" step for it, same as this suite's own product-name/SKU
  # fixtures elsewhere, rather than a fixed string that would only work
  # once.
  #
  # Order ID 1 is generic seed/test order data (customer
  # "support@peracto.io", Purchase Order "test PO") - confirmed live this
  # sends successfully with a fresh reference, on both staging and the
  # release branch. Order ID 175 was used here previously (a real order on
  # STAGING, placed by this suite's own admin/checkout account, tagged
  # "Velstar Test") and worked fine there - but staging and
  # MIPA_ADMIN_RELEASE are separate databases with different order data,
  # and per the user, order 175 doesn't exist on the release branch at all
  # (its last real order is 164) - that mismatch, not a platform bug, is
  # why it 500'd there ("Internal Server Error" is just this harness's
  # generic failure response for a nonexistent order, not a "not found"
  # message). Order 1 is used instead because it's real data on BOTH
  # environments, so this scenario isn't tied to one environment's
  # order history the way a hardcoded staging-only ID would be.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): BC's own "No." field
  # has a hard 20-character limit - a longer reference is rejected with
  # "The length of the string is X, but it must be less than or equal to
  # 20 characters", confirmed via the existing "qa-<timestamp>" unique
  # value format (16 characters), which fits safely.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): resending the exact
  # same reference twice is correctly rejected by BC itself as a
  # duplicate key, not silently accepted or silently no-op'd - real
  # idempotency-guard behaviour worth locking in as its own scenario.

  Scenario: Sending a real order with a unique reference successfully forwards it to the ERP
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Test Harnesses" element
    And I click precisely on the "Send Order" element
    And I fill in the "Order ID" input field with "1"
    And I fill in the "Order Reference" input field with a unique value, remembering it as "order reference"
    And I click precisely on the "Submit" element
    Then the "response details" should contain the remembered "order reference", case-insensitively
    And the "response details" should contain the text "Pending"


  Scenario: Sending an order twice under the same reference is rejected as a duplicate
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Test Harnesses" element
    And I click precisely on the "Send Order" element
    And I fill in the "Order ID" input field with "1"
    And I fill in the "Order Reference" input field with a unique value, remembering it as "duplicate order reference"
    And I click precisely on the "Submit" element
    Then the "response details" should contain the remembered "duplicate order reference", case-insensitively

    When I fill in the "Order ID" input field with "1"
    And I fill in the "Order Reference" input field with the remembered "duplicate order reference"
    And I click precisely on the "Submit" element
    Then the "error toast" should contain the text "already exists"
