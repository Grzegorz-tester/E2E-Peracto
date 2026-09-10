@regression @mutates-admin-data
Feature: Product Variant Creation and Deletion

  # New coverage (2026-09-10) - Peracto Admin has no standalone "Add
  # Variant" button; a Product must first have at least one Product Option
  # (e.g. "Size") added and saved on its own detail page, which then reveals
  # a "Manage Variants" link to a per-product Product Variants list with its
  # own "Add Product Variant" button. Confirmed live (Andy Thornton AT-171
  # admin release branch, 2026-09-10) - built on the same disposable
  # create-then-delete product as product-management.feature, so it doesn't
  # touch any real, pre-existing product's real options/variants. Tagged
  # @mutates-admin-data with the same "I require a staging admin" runtime
  # guard as every other write scenario in this suite.
  #
  # CONFIRMED (live, Andy Thornton, 2026-09-10):
  # - The Add Product Variant form and an existing variant's edit form share
  #   the exact same field testids (sku/option-0-display-value/price/
  #   product-status-dropdown/save-form) - both resolve through the same
  #   "product-variant-detail" page mapping, no separate "add" page needed.
  # - Saving the product with a new Option shows a "Product successfully
  #   updated!" toast (the same generic product-save toast, not a
  #   variant-specific one).
  # - The Option's "Display Value" (what a shopper sees, e.g. "Large") is a
  #   separate, required field from the underlying Option's own Label/
  #   Identifier ("Size"/"size") set up on the parent product - confirmed
  #   both are needed for the variant to save.
  # - Only ONE other tenant has been checked so far (Andy Thornton) - not
  #   yet cross-verified against a second tenant like product-detail.json
  #   was (MIPA + Indespension independently matched). Watch for gaps on
  #   other tenants' first real runs.
  # - Deleting a variant redirects back to the per-product Product Variants
  #   list with the same short async delay as the save-redirect above -
  #   confirmed live an immediate "Add Product Variant" element check right
  #   after confirming deletion throws "no selector resolved" (the current
  #   page still resolves to the just-deleted variant's own detail page,
  #   whose mapping has no such key) rather than failing the assertion -
  #   getElementLocator resolves the page ID ONCE up front, not on every
  #   waitFor poll, so it can't self-heal once the redirect completes a
  #   moment later. Fixed with the existing "I wait for the page to settle"
  #   step (networkidle + 1s buffer) before the check.
  # - Saving a NEW variant does NOT redirect away from its "/add" URL the
  #   way saving a new Product/Page/Article does - confirmed live the save
  #   genuinely succeeds (the record exists, reachable from the Product
  #   Variants list) but the SPA navigates to the new variant's own URL
  #   with a short async delay. A loose "current URL should contain
  #   '.../variants/'" check matches the stale "/add" URL too and passes
  #   instantly without ever waiting for the real navigation - confirmed
  #   live this produces a false pass, then "I reload the page" reloads
  #   the still-blank "/add" form instead of the new variant, failing the
  #   very next persistence check. Fixed with "current URL should not
  #   contain '/add'" instead, which genuinely polls (via waitFor) until
  #   the real redirect completes.
  #
  # Cleanup order matters: delete the variant record first, THEN remove the
  # Option row from the product and save, THEN delete the disposable
  # product itself - same "delete what you created, in dependency order"
  # discipline as content-creation.feature/product-management.feature, so
  # repeated regression runs don't pile up disposable products, options or
  # variants in any tenant's real catalogue.

  Scenario: Adding a Product Option and a Variant to a new product, then deleting both
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I click precisely on the "Add Product" element
    And I select the "Default" option from the "Attribute Set" react-select, typing to search
    And I fill in the "Product Name" input field with a unique product name
    And I fill in the "SKU" input field with a unique product SKU
    And I fill in the "Price" input field with "9.99"
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Product successfully added!"

    When I click precisely on the "Add New Option" element
    And I fill in the "Option Label" input field with "Size"
    And I fill in the "Option Identifier" input field with "size"
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Product successfully updated!"

    When I click precisely on the "Manage Variants" element
    Then the current URL should contain "/variants"
    And I click precisely on the "Add Product Variant" element
    Then the current URL should contain "/variants/add"

    When I fill in the "SKU" input field with a unique product SKU
    And I fill in the "Option Value" input field with "Large"
    And I fill in the "Price" input field with "12.99"
    And I select the "Active" option from the "Product Status" react-select
    And I click precisely on the "Save" element
    Then the current URL should not contain "/add"

    When I reload the page
    Then the "SKU" input field should have the stored product SKU
    And the "Option Value" should equal the value "Large"
    And the "Price" should equal the value "12.99"
    And the "Product Status" should contain the text "Active"

    When I click precisely on the "Delete Variant" element
    And I click precisely on the "Confirm Delete Variant" element
    And I wait for the page to settle
    Then the "Add Product Variant" should be displayed

    When I click precisely on the "Back to Product" element
    And I click precisely on the "Remove Option" element
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Product successfully updated!"

    When I click precisely on the "Delete Product" element
    And I click precisely on the "Confirm Delete Product" element
    Then the "success toast" should contain the text "Product deleted successfully!"
