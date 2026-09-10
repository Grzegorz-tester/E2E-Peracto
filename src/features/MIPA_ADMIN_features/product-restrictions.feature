@regression
Feature: Product Restrictions

  # Bespoke to MIPA, not the shared Carbon_admin boilerplate suite -
  # confirmed live "Product Restrictions" (a Products sub-nav item,
  # between Product Variants and Categories) is NOT part of the common
  # Peracto Admin setup: present on MIPA Admin, absent on Carbon Admin,
  # the reference tenant the shared suite is modelled on. Same reasoning
  # as file-manager.feature/tasks.feature.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): this is a per-SKU/
  # per-trade-account restriction table (SKU, Account Number, Full
  # Restricted), not a standard Peracto list - its rows have no detail
  # link at all (no href on any row), the same genuine "nothing to click
  # through to" shape already documented for Countries in
  # first-item-redirects.feature, so no first-item-redirect check applies
  # here either.
  #
  # Its own Export Product Restrictions Data page (reached via a real nav
  # link, not just a direct URL) behaves exactly like products-export.
  # feature's exports - reuses the same generic download-capturing steps
  # (file-download.ts).
  #
  # Import Product Restrictions Data is deliberately NOT covered here:
  # confirmed live it's a real bulk file upload that overwrites/adds
  # restriction rules across MIPA's real product catalogue - unlike a
  # single disposable test product, there's no narrow, easily-reversible
  # scope to a bad import here, so this is left untested for now (same
  # caution as test-harness-import-payment.feature's real-financial-write
  # concern).

  Scenario: The Product Restrictions tab loads with its own real restriction data
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Product Restrictions" element
    Then I should be redirected to the "product-restrictions" page
    And the "page heading" should contain the text "Product Restrictions"
    And the "table row" should be displayed


  Scenario: Exporting Product Restrictions downloads a real restriction CSV
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Product Restrictions" element
    And I click precisely on the "Export Product Restrictions Data" element
    Then I should be redirected to the "product-restrictions-export" page
    When I click on the "Export Product Restrictions" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_restriction_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "productSku,accountNumber,fullRestriction"
