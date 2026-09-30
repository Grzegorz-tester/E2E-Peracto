@regression @mutates-admin-data @product-variants
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
  # @product-variants added (2026-09-17) - the same tag the two Product
  # Variants nav rows already use, so a tenant without variants excludes
  # this whole file with the tag it already sets. CONFIRMED (live, Lamona
  # release branch 2-8-0): this tenant has variants switched off entirely,
  # not just hidden - its Product Type dropdown offers ONE option
  # ("Standard", no variant-capable type), a saved product's detail page
  # renders no options/variants section at all (no add-variant-option, and
  # the page text never contains "Variant" or "Option"), the advanced-
  # options toggle reveals nothing variant-related, and there's no Product
  # Variants nav tab. So the scenario fails at "Add New Option" AFTER
  # creating its product but BEFORE its own delete-product cleanup, leaving
  # an orphaned test product behind on every run - which is how three
  # "Velstar Test Product ..." rows accumulated there before this was
  # tagged.
  #
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
  # CONFIRMED SITE-SPECIFIC (live, KOOL_ADMIN_RELEASE, 2026-09-15): shares the
  # same required Ugly Freight/Searchable in Storefront/Searchable in Quote
  # Tool fields as product-management.feature's own initial product create -
  # see that file's own note for the full 422 root cause. Filled the same
  # way here via the "... react-select if present" step.
  #
  # RETRACTED "async redirect race" DIAGNOSIS, ROOT-CAUSED (live,
  # Keylite_ADMIN_RELEASE, 2026-09-16): "current URL should not contain
  # '/add'" timed out after a variant Save on this tenant only. Looked at
  # first like the same slow-SPA-redirect pattern documented above (Andy
  # Thornton), but a raw Playwright repro with network/console logging
  # showed the Save click never fired any API request at all - client-side
  # validation silently blocked it. Keylite's product-variant form has two
  # extra required fields, "Nav SKU"/"Nav Product Name"
  # ([data-testid='navSku']/[data-testid='navProductName']), presumably
  # feeding a Nav/ERP integration - not present as a requirement on any
  # other tenant checked so far. No toast, no error banner, nothing but
  # inline "is a required field" text under those two fields, so the
  # scenario had no visible signal at all that it was blocked. Same shape
  # as MIPA's "Account Number" gap on the Add User form (see form.ts) - a
  # tenant-only required field, not a real site defect. Fixed generically
  # with the same "... input field with a unique value if present" step
  # used there, so every other tenant (where these fields don't exist) is
  # an unaffected no-op. Added the two testids to Keylite's own
  # product-variant-detail.json mapping only.
  #
  # RETRACTED "REAL BACKEND BUG" CALL, ROOT-CAUSED (live, Keylite_ADMIN_
  # RELEASE, 2026-09-16): with the Nav SKU/Nav Product Name gap fixed, the
  # scenario still failed at the same assertion - first mistaken for a
  # genuine site defect after one raw-script repro returned a hard 500,
  # but the user manually tested the exact same flow by hand and it worked
  # fine, which is what prompted a closer look (per this repo's own
  # "verify before concluding" habit - a manual pass is stronger evidence
  # than a repeated automated one, same lesson as the HIB "Manage Variants"
  # retraction above). Two more real gaps stacked on top of each other,
  # both confirmed via raw network capture:
  # - product-admin.ts's disposable SKU generator produces
  #   "VEL-TEST-<Date.now()>", 22 characters - Peracto Admin's Product
  #   Variant Save rejects any SKU over 20 chars with a 422 ("Products
  #   'Sku' exceeds the character limit of 20."), shown as a genuine error
  #   toast the very first repro script missed because it only checked the
  #   page's body text for "required|error|must|invalid" - "exceeds the
  #   character limit" matches none of those. Fixed generically in
  #   product-admin.ts by truncating the generated SKU to a safe length -
  #   benefits every tenant using this shared step, not just Keylite.
  # - Even with a safely short SKU, Save still 500'd - Keylite's variant
  #   form has two more fields, "Lead Time (GB)"/"Lead Time (IE)"
  #   ([data-testid='leadTimeGB']/[data-testid='leadTimeIE']), that are
  #   required at the API level but have NO client-side validation at all
  #   (no "required field" text, no toast) - omitting them serializes as
  #   missing/null in the POST body and the API answers with a bare
  #   "500 Internal Server Error" instead of a helpful message, which is
  #   what made this look like a real site defect for a lot longer than it
  #   should have. Filling both with any valid number (confirmed live:
  #   "5"/"7") produces a clean 201 and the real redirect away from
  #   "/add". Fixed with a new generic "... with 'X' input field... if
  #   present" step (form.ts) mirroring the existing unique-value one, and
  #   added both testids to Keylite's own product-variant-detail.json
  #   mapping only - a no-op on every tenant without these fields.
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
    And I select the "No" option from the "Ugly Freight" react-select if present
    And I select the "Yes" option from the "Searchable in Storefront" react-select if present
    And I select the "Yes" option from the "Searchable in Quote Tool" react-select if present
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
    And I fill in the "Nav SKU" input field with a unique value if present
    And I fill in the "Nav Product Name" input field with a unique value if present
    And I fill in the "Lead Time (GB)" input field with "5" if present
    And I fill in the "Lead Time (IE)" input field with "7" if present
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
