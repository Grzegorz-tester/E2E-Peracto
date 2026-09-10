@regression
Feature: Test Harness - Import Payment

  # Bespoke to MIPA - see test-harness-get-product.feature for why the
  # whole Test Harnesses section lives in its own project-specific path
  # rather than the shared Carbon_admin folder.
  #
  # Only the REJECTION path is covered here, deliberately. Unlike Send
  # Order (which is safely resendable under a fresh reference each time),
  # a genuinely successful Import Payment writes a real payment/ledger
  # record against a real customer's account balance in Business Central
  # with no equivalent "undo" available to this suite - there's no
  # disposable-and-then-deletable equivalent here the way a test product
  # can be created and deleted. Confirmed live instead that an invalid
  # "Payment Type" is rejected by BC's own real validation before any
  # record is written - "CARD" doesn't exist in BC's E-Commerce Payment
  # Setup table, and submitting it returns a real BC error object
  # rendered in the same #response-details panel every other harness
  # uses (confirmed live this particular rejection surfaces there, not as
  # a Toastify notification):
  # "The field Payment Type of table D365AG0 Ecom. Cust. Payment contains
  # a value (CARD) that cannot be found in the related table (E-Commerce
  # Payment Setup)." This still proves the harness is correctly wired to
  # the real ERP and its validation, without ever completing a real,
  # unreversed financial write. If a genuinely safe way to test the
  # success path emerges (e.g. a dedicated sandbox payment type meant for
  # this), extend this feature rather than replacing this scenario.

  Scenario: Submitting an invalid Payment Type is rejected by the real ERP validation
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Test Harnesses" element
    And I click precisely on the "Import Payment" element
    And I fill in the "User Email" input field with the "admin" user's email
    And I fill in the "Payment Type" input field with "CARD"
    And I fill in the "Currency Code" input field with "GBP"
    And I fill in the "Amount" input field with "0.01"
    And I fill in the "Auth Code" input field with "INVALID-TEST-AUTH-CODE"
    And I click precisely on the "Submit" element
    Then the "response details" should contain the text "cannot be found in the related table"
