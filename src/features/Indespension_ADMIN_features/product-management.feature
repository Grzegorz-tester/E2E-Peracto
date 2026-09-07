@regression
Feature: Product Creation and Publishing

  # Bespoke to Indespension, not the shared Carbon_admin boilerplate suite:
  # unlike that suite's read-only nav sweep, this scenario WRITES data
  # (creates, publishes, then deletes a product), which is only safe on a
  # staging admin - see CLAUDE.md's "Staging vs production rules" (a
  # production admin is read-only: no creating/editing/deleting anything).
  # Indespension has no production admin env in this repo today, but the
  # shared Carbon_admin folder IS reused by tenants that DO have one (e.g.
  # KOOL_ADMIN_PROD.env) - so this scenario deliberately lives in its own
  # Indespension-only feature path (env/INDESPENSION_ADMIN.env's
  # FEATURE_PATH) rather than the shared folder, and must stay that way
  # rather than being moved/copied into Carbon_admin. Same structure as
  # MIPA_ADMIN_features/product-management.feature, which this was copied
  # from - keep the two in sync if the underlying Peracto Admin product
  # form changes.
  #
  # CONFIRMED (live, INDESPENSION_ADMIN staging, 2026-08-27 - same
  # selectors as MIPA/Carbon Admin, since all three run the same underlying
  # Peracto Admin product per CLAUDE.md; independently re-verified end to
  # end against Indespension itself, including a full
  # create -> reload -> delete cycle):
  # - An Attribute Set must be chosen before Product Type/Status/
  #   Availability/Sales Unit/Tax rate become enabled - they're disabled
  #   placeholders (defaulting to Standard/Draft/Purchasable/Each/Standard)
  #   until then, same as MIPA.
  # - Those react-select fields render with no ARIA roles at all (no
  #   role=combobox/listbox/option), so the "... react-select" step in
  #   form.ts is required here too.
  # - "Index Product" triggers an immediate reindex rather than waiting on
  #   a scheduled job. On Indespension, same as MIPA (unlike Carbon Admin's
  #   plain visible checkbox), its native checkbox is visually hidden
  #   behind custom styling and defaults to already checked - the "I ensure
  #   the ... checkbox is checked" step in check.ts handles this.
  # - Setting Product Status to "Active" and saving is genuinely what
  #   "publish" means here - confirmed by reloading the saved product and
  #   seeing "Active" still there, not just trusting a success toast.
  #
  # Deletes what it creates at the end so repeated regression runs don't
  # pile up disposable products in Indespension's real product catalogue.

  Scenario: Creating a product with required fields and publishing it
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I click precisely on the "Add Product" element
    And I select the "Default" option from the "Attribute Set" react-select
    And I fill in the "Product Name" input field with a unique product name
    And I fill in the "SKU" input field with a unique product SKU
    And I fill in the "Price" input field with "9.99"
    And I ensure the "Index Product" checkbox is checked
    And I select the "Active" option from the "Product Status" react-select
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Product successfully added!"
    And the "Price" should equal the value "9.99"

    When I reload the page
    Then the "Product Name" input field should have the stored product name
    And the "SKU" input field should have the stored product SKU
    And the "Product Status" should contain the text "Active"

    When I click precisely on the "Delete Product" element
    And I click precisely on the "Confirm Delete Product" element
    Then the "success toast" should contain the text "Product deleted successfully!"
