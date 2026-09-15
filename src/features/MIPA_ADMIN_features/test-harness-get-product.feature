@regression
Feature: Test Harness - Get Product

  # Bespoke to MIPA, not the shared Carbon_admin boilerplate suite - the
  # "Test Harnesses" section (Get Prices, Get Invoices, Get Account
  # Balance, Get Product, Get Customer, Get Sales Orders, Send Order,
  # Import Payment) is MIPA's own bespoke tab, not part of the standard
  # Peracto Admin nav every other tenant has, so per CLAUDE.md this gets
  # its own small project-specific feature file rather than being added to
  # the shared folder (which would then try to run against every other
  # tenant, none of which have this tab). Only "Get Product" is covered
  # here, on request - the other seven Test Harness pages are out of
  # scope for now.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-08-30): Get Product is a
  # thin diagnostic UI over MIPA's real Business Central/Dynamics ERP
  # integration, not a Peracto-side lookup - submitting a SKU makes a live
  # call out to that ERP and renders its raw JSON response verbatim (under
  # a `#response-details` panel) - "DC Get Product Response" -> a
  # `@odata.context`/`value[]` payload containing that same product's own
  # `no` (SKU), description, attributes, inventory, etc. Read-only (a
  # lookup, not a write), so this is safe to run repeatedly with no
  # cleanup needed, unlike the content-creation/task-triggering scenarios
  # elsewhere in this folder.
  #
  # Uses whichever SKU is genuinely first NUMERIC-looking one in the real
  # Products list right now, rather than a hardcoded one - a fixed SKU is
  # a one-shot value that could stop existing (or get deactivated) later,
  # the same reason this suite prefers "click the first item" over a
  # specific one elsewhere (see e.g. Indespension's towbar fitting-slot
  # picker). Verifies the response genuinely reflects THAT SKU coming
  # back from the ERP, not just that some response panel rendered.
  #
  # CONFIRMED (live, MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08): plain "first
  # row" isn't reliable here - that environment's row 0 was a manually
  # seeded QA product with name AND "SKU" both literally "test may",
  # never synced to the real ERP, which made the harness call come back
  # with an empty `value: []` (a real bug caught rather than a flake, but
  # not the one this scenario is meant to catch). Real SKUs are always
  # numeric (the harness's own "SKU" field placeholder gives
  # "002675029143" as its example) - matching the first row whose SKU
  # actually looks like one sidesteps stray test/placeholder rows like
  # that without hardcoding a specific product.

  Scenario: Looking up a real product by SKU returns its own ERP data
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I remember the text of the first "product SKU" matching the pattern "^\d+$" as "test harness sku"
    And I click precisely on the "Test Harnesses" element
    And I click precisely on the "Get Product" element
    And I fill in the "SKU" input field with the remembered "test harness sku"
    And I click precisely on the "Submit" element
    Then the "response details" should contain the remembered "test harness sku"
