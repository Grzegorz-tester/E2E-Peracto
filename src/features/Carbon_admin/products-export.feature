@regression
Feature: Exporting Product Data

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - per the user directly, this is standard Peracto Admin
  # functionality, not a MIPA-specific bespoke feature. Confirmed live on
  # Andy Thornton (a completely independent tenant): all 9 export buttons
  # exist with identical testids, and downloading all 9 there produced
  # byte-for-byte matching filenames and matching CSV header row prefixes
  # to MIPA's (extra trailing columns on Andy Thornton's exports are just
  # its own custom product attributes - the "should start with the text"
  # assertions below already tolerate that, they don't require an exact
  # match). No @mutates-admin-data tag needed - unlike every other
  # promoted write scenario in this suite, exporting data is read-only, so
  # this is safe to run against a production admin too.
  #
  # Reached from a real "Export Product Data" link on the All Products
  # list (confirmed live on both tenants), not just a direct URL - added
  # the "Export Product Data"/products-export mapping keys and the
  # products-export.json detail file (previously only in MIPA's config,
  # confirmed identical values on Andy Thornton) to every other tenant on
  # promotion.
  #
  # CONFIRMED (live, MIPA_ADMIN staging and release_branch, 2026-09-08 +
  # Andy Thornton, 2026-09-10): every one of the 9 export buttons on this
  # page triggers an immediate real CSV download (no async job/queue, no
  # toast) - each with its own distinct filename and CSV header row. All 9
  # are exercised independently so a single broken export doesn't hide
  # whether the other 8 still work. Sizes vary hugely by design
  # (Relationships/Inventory exports are genuinely tiny right now - real
  # low data, not a broken export) - this only asserts non-empty and a
  # correct header row, not a specific size.
  #
  # CONFIRMED (live, HIB_ADMIN release branch, 2026-09-11): the Attributes
  # export's header row is NOT the same column order on every tenant - HIB's
  # starts "product,range,product_features,swatch,..." rather than
  # "product,product_name,description,...", but all the expected columns
  # are genuinely present, just interleaved with HIB's own custom
  # attributes rather than only appended at the end (which is what the
  # "should start with the text" prefix match above already tolerated).
  # Switched that one scenario to the order-independent "header row should
  # contain the columns" step (file-download.ts) instead of loosening or
  # removing the assertion - the other 8 exports keep the strict prefix
  # match since those were confirmed to match exactly across tenants.

  Background:
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I click precisely on the "Export Product Data" element
    Then I should be redirected to the "products-export" page

  Scenario: Exporting Products downloads a real product CSV
    When I click on the "Export Products" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "sku,mpn,gtin,slug,attributeSet,status,availability,display"

  Scenario: Exporting Variants downloads a real product variant CSV
    When I click on the "Export Variants" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_variant_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "productSku,variantSku,rrp,price,salePrice,clearancePrice"

  Scenario: Exporting Attributes downloads a real attribute-value CSV
    When I click on the "Export Attributes" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_attribute_export_1_100.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download's header row should contain the columns "product,product_name,description"

  Scenario: Exporting Resources downloads a real product-resource CSV
    When I click on the "Export Resources" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_resource_export_1_100.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "product,type,location,displayOrder,title,description"

  Scenario: Exporting Relationships downloads a real product-relationship CSV
    When I click on the "Export Relationships" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_relation_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "primaryProduct,relatedProduct,relationship,quantity,displayOrder"

  Scenario: Exporting Product Inventory downloads a real inventory CSV
    When I click on the "Export Product Inventory" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_inventory_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "product,location,stockLevel,outOfStockLevel"

  Scenario: Exporting Product Options downloads a real product-option CSV
    When I click on the "Export Product Options" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_option_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "product,optionIdentifier,optionLabel,optionType,optionDisplayOrder"

  Scenario: Exporting Product Variant Options downloads a real product-variant-option CSV
    When I click on the "Export Product Variant Options" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_variant_option_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "productVariant,productOption,identifier,displayValue,altValue"

  Scenario: Exporting Product Variant Inventory downloads a real variant-inventory CSV
    When I click on the "Export Product Variant Inventory" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "product_variant_inventory_export.csv"
    And the remembered "export" download should not be empty
    And the remembered "export" download should start with the text "productVariant,location,stockLevel,outOfStockLevel"
