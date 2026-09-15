@regression @mutates-admin-data
Feature: Product Creation and Publishing

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - Product creation is standard Peracto Admin functionality.
  # Its detail-page selectors (product-detail.json: Attribute Set/Product
  # Name/SKU/Price/Product Status/Index Product/Save/Delete Product/Confirm
  # Delete Product) were previously only defined in MIPA's config, but
  # Indespension had independently built an IDENTICAL file (same testids,
  # same XPath for Product Status) - strong evidence this is universal, not
  # a coincidence. Copied to every other tenant on promotion. Tagged
  # @mutates-admin-data with the same "I require a staging admin" runtime
  # guard as every other write scenario in this suite, since the shared
  # folder is reused by tenants with a production admin env (e.g.
  # KOOL_ADMIN_PROD.env).
  #
  # Merged in from a since-removed Indespension-specific duplicate of this
  # same scenario (written 2026-08-27, before this file was shared -
  # discovered via scripts/check-duplicate-admin-features.sh) rather than
  # lost on cleanup: CONFIRMED (live, Indespension staging, 2026-08-27,
  # independently re-verified end to end including a full
  # create -> reload -> delete cycle) identical to MIPA/Carbon Admin in
  # every respect checked - a third independent tenant confirmation of
  # this scenario's universality, on top of the config-file match noted
  # above.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-08-27 + Andy Thornton AT-171
  # admin release branch, 2026-09-10):
  # - An Attribute Set must be chosen before Product Type/Status/
  #   Availability/Sales Unit/Tax rate become enabled - they're disabled
  #   placeholders (defaulting to Standard/Draft/Purchasable/Each/Standard)
  #   until then.
  # - Those react-select fields render with no ARIA roles at all (no
  #   role=combobox/listbox/option), so neither the generic "... dropdown"
  #   step (real <select> only) nor "... listbox" step (Radix role-based)
  #   apply - see the "... react-select" step in form.ts.
  # - CONFIRMED (live, Andy Thornton, 2026-09-10): unlike Product Type/
  #   Status/Availability/Sales Unit/Tax rate (a short fixed list, visible
  #   immediately on open), "Attribute Set" shows no options at all until
  #   text is typed - a real catalog can have many attribute sets, so this
  #   one loads async. Uses the "... react-select, typing to search"
  #   step variant instead of the plain one for this field specifically.
  # - CONFIRMED (live, Andy Thornton, 2026-09-10): SKU does NOT
  #   auto-populate from the Product Name field (still empty after filling
  #   Product Name and blurring) - filled explicitly below, same as MIPA.
  # - "Index Product" checkbox state varies by tenant: on MIPA it's
  #   visually hidden behind a styled label/span and already checked by
  #   default; on Andy Thornton it's plainly visible and already checked.
  #   The "I ensure the ... checkbox is checked" step (check.ts) handles
  #   both transparently - it reads/sets state via the DOM rather than
  #   requiring Playwright's "visible" check, and only clicks if it isn't
  #   already checked.
  # - Setting Product Status to "Active" and saving is genuinely what
  #   "publish" means here - confirmed by reloading the saved product and
  #   seeing "Active" still there, not just trusting a success toast.
  # - Login timing varies by tenant - MIPA's own admin genuinely takes
  #   ~12s to redirect (its SCRIPT_TIMEOUT is bumped to 35000 for this);
  #   bump SCRIPT_TIMEOUT per-project if login timeouts show up elsewhere.
  #
  # Deletes what it creates at the end so repeated regression runs don't
  # pile up disposable products in any tenant's real product catalogue.
  #
  # Also edits the Price after the initial create+publish, on the same
  # disposable product, before deleting it - added because
  # editing-existing-entities.feature's Category scenario caught a real
  # "id" type-coercion bug on a plain save, so exercising the same save
  # code path for Products (via an edit, not just a create) is worth the
  # extra two steps. CONFIRMED (live, MIPA_ADMIN staging, 2026-09-09): a
  # plain field edit+save on an existing product shows NO success toast
  # at all (unlike create's "Product successfully added!" or delete's
  # "Product deleted successfully!") - the price genuinely does persist
  # (confirmed via reload), so this only asserts on the persisted value,
  # not a toast that was never going to appear.

  Scenario: Creating a product with required fields and publishing it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I click precisely on the "Add Product" element
    And I select the tenant's default attribute set from the "Attribute Set" react-select, typing to search
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

    When I fill in the "Price" input field with "19.99"
    And I click precisely on the "Save" element
    And I reload the page
    Then the "Price" should equal the value "19.99"

    When I click precisely on the "Delete Product" element
    And I click precisely on the "Confirm Delete Product" element
    Then the "success toast" should contain the text "Product deleted successfully!"
