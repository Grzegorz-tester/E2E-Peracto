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

  # RETRACTED FALSE BUG REPORT, ROOT-CAUSED (live, HIB_ADMIN release
  # branch, 2026-09-13): first logged here as a "confirmed bug" (Manage
  # Variants silently not navigating) after reproducing a failure twice
  # via automation - but the user then manually tested the same flow by
  # hand and Manage Variants worked fine and quickly, directly
  # contradicting that conclusion. Traced the real mechanism live: the
  # "Option Identifier" field auto-populates itself with the slugified
  # Label value the INSTANT it's focused (confirmed: focusing an empty
  # identifier field alone fills it with "size" before any typing).
  # Automation (both Playwright's fill() and character-by-character
  # type() alike) focuses the field and then adds its own "size" on top
  # of that just-appeared auto-value, producing "sizesize" - which left
  # the form permanently dirty and made "Manage Variants" a no-op. A real
  # user never hits this: they see the field already correctly
  # auto-populated and don't redundantly retype the same value into it.
  # This was a test-automation gap, not a site defect - fixed by using
  # "... clearing any auto-populated value first" (form.ts/
  # html-behaviour.ts, added 2026-09-13) for this one field instead of
  # changing the plain fill step for everyone else. Left as a cautionary
  # note rather than deleted outright: an automated repro that looks
  # "confirmed" via a second independent reproduction can still be wrong
  # if the reproduction method itself (not just the one run) is what's
  # flawed - a live manual test is stronger evidence than repeating the
  # same automated approach twice.
  #
  # SECOND ROUND, RESOLVED (2026-09-13, same day): with the identifier fix
  # applied, "Manage Variants" still didn't navigate in three further
  # automated attempts (confirmed the click lands on the real nested
  # <button>, not an overlay; no new tab opens). Per the user, it worked
  # fine and quickly when tested manually - and confirmed visible
  # "straight away" with no flicker, ruling out a plain visibility race.
  # A direct DOM check then caught it: querying for
  # "[data-testid='button-manage-variants']" right after the Option save
  # sometimes returned ZERO matches, even though a plain click() on the
  # same selector moments earlier had succeeded without complaint - the
  # element was appearing/disappearing across an async re-render window
  # right after saving, same general shape as this file's OWN documented
  # "Manage Variants" first-appears-after-save race (see the CONFIRMED
  # (live, Andy Thornton...) note above), just a narrower/less consistent
  # window on HIB. CONFIRMED FIX: adding "I wait for the page to settle"
  # (navigation.ts - networkidle + 1s buffer, already used elsewhere in
  # this same file for the equivalent post-delete race) before clicking
  # "Manage Variants" made the very first click succeed reliably. Not a
  # backend propagation/indexing delay after all - the settle wait alone
  # was sufficient, no extra delay beyond its own ~1s buffer was needed.
  Scenario: Adding a Product Option and a Variant to a new product, then deleting both
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I click precisely on the "Add Product" element
    And I select the tenant's default attribute set from the "Attribute Set" react-select, typing to search
    And I fill in the "Product Name" input field with a unique product name
    And I fill in the "SKU" input field with a unique product SKU
    And I fill in the "Price" input field with "9.99"
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Product successfully added!"

    When I click precisely on the "Add New Option" element
    And I fill in the "Option Label" input field with "Size"
    And I fill in the "Option Identifier" input field with "size", clearing any auto-populated value first
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Product successfully updated!"

    When I wait for the page to settle
    And I click precisely on the "Manage Variants" element
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
