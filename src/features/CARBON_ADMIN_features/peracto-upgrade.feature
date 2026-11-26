@regression @peracto-v13
Feature: Peracto Admin v13 upgrade checks (PER3-279)

  # PER3-279: Peracto Admin React 16 -> 19 (v13.0.0-alpha), react-scripts 3 ->
  # 5 (webpack 5, CRACO), CKEditor 34 -> 49, Bootstrap and @chakra-ui/core
  # removed (Tailwind only), @peracto/peracto-blocks replaced, route-level
  # code splitting (the initial bundle no longer carries the content editor
  # or the PDF tools), a hardened upload file-type check, and (raised later)
  # Axios swapped for fetch. Release host: react-19-peracto.peracto3carbon.pub
  # (env/CARBON_ADMIN_RELEASE.env), which talks to the SAME staging API as
  # staging-peracto, so CRUD here is staging data.
  #
  # Built 2026-11-25 from a live comparison of the release build against
  # staging (still React 16). Covers only what the shared
  # CARBON_ADMIN_SHARED_features suite doesn't:
  #   - every screen deep-loads its own lazy chunk with no JS error or failed
  #     API call (code splitting; a stale or missing chunk only shows on a
  #     direct load, never via in-app nav once the chunk is cached)
  #   - the content editor's blocks (the editor UI itself was redesigned:
  #     labelled toolbar, Add blocks / Block settings panel, click-to-add,
  #     per-block toolbar) - the shared suite only renames content
  #   - CKEditor typing and formatting persisting through a save
  #   - order view, pick list PDF (lazy @react-pdf chunk), order export
  #     (react-datepicker), Create Order screen - no shared coverage at all
  #   - the other CSV exports and a CSV import (multipart upload through
  #     fetch rather than Axios)
  #   - list pagination, sorting, rows per page and Manage Columns
  #     (querystring polyfill added for webpack 5)
  #   - every Settings tab, Customer Groups, product modals (Bootstrap modal
  #     JS replaced), logout
  #
  # NOT covered here (can't be on Carbon): the hardened upload file-type
  # check (.pdf/.txt/.png/.jpg/.jpeg only, "Invalid file type..." toast)
  # lives in the resource Upload buttons, which only render when
  # features.uploads is on - it's off on Carbon (Browse/CKFinder only).
  # Needs a tenant with uploads on once v13 rolls out.
  #
  # Kept Carbon-only (CARBON_ADMIN_features) until v13 reaches other tenants;
  # promote to CARBON_ADMIN_SHARED_features then (run
  # scripts/check-duplicate-admin-features.sh first), copying the new
  # mapping keys/files to every tenant.

  Background:
    Given I am navigating the page as a "admin" user

  # Code splitting: a direct load of each route fetches its own chunk.
  # "requestStorageAccess" is CKFinder's third-party-storage probe, seen on
  # staging (React 16) too - not an app error.
  Scenario Outline: The <heading> screen loads directly with no JS error or failed API call
    Given I start monitoring console errors, ignoring messages matching "requestStorageAccess"
    And I start monitoring failed network responses from hosts matching "peracto3carbon\.pub"
    When I am on the "<page id>" page
    And I wait for the page to settle
    Then the "page heading" should contain the text "<heading>"
    And there should be no unexpected console errors
    And there should be no failed network responses

    Examples:
      | page id                      | heading                      |
      | orders                       | Orders                       |
      | orders-create                | Create Order                 |
      | products                     | Products                     |
      | products-export              | Export Product Data          |
      | products-import              | Bulk Manage Data             |
      | variants                     | Product Variants             |
      | categories                   | Categories                   |
      | attributes                   | Attributes                   |
      | attributes-import            | Import Attribute Data        |
      | attribute-groups             | Attribute Groups             |
      | attribute-sets               | Attribute Sets               |
      | promotions                   | Promotions                   |
      | pages                        | Pages                        |
      | articles                     | Articles                     |
      | article-categories           | Article Categories           |
      | templates                    | Templates                    |
      | elements                     | Elements                     |
      | element-areas                | Element Areas                |
      | forms                        | Forms                        |
      | form-fields                  | Form Fields                  |
      | form-submissions             | Form Submissions             |
      | form-submissions-export      | Export Form Submission Data  |
      | locations                    | Locations                    |
      | locations-export             | Export Location Data         |
      | locations-import             | Import Location Data         |
      | users                        | Users                        |
      | users-export                 | Export User Data             |
      | user-groups                  | User Groups                  |
      | customer-groups              | Customer Groups              |
      | settings                     | Settings                     |
      | navigation                   | Navigation                   |
      | redirects                    | Redirects                    |
      | redirects-import             | Import Redirect Data         |
      | shipping-services            | Shipping Services            |
      | tasks                        | Tasks                        |
      | countries                    | Countries                    |

  # ---------------------------------------------------------------- content

  # The editor UI was rebuilt for v13. All block edits happen before the one
  # save, so leaving the page never meets an unsaved-changes prompt.
  @mutates-admin-data
  Scenario: Adding, undoing, duplicating and deleting a Text block, then saving typed text, persists after a reload
    Given I require a staging admin for this scenario
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "Create New Page" element
    And I wait for the page to settle
    # The page-settings panel opens over the canvas on a new page; close it
    # to reach the blocks, as a person would.
    And I click precisely on the "Content settings toggle" element
    Then the "open content settings panel" should not be visible
    When I remember the number of "text block" elements as "text blocks before"

    When I click precisely on the "Text block" element
    Then the number of "text block" elements should be more than the remembered "text blocks before"
    When I click precisely on the "Undo" element
    Then the number of "text block" elements should equal the remembered "text blocks before"
    When I click precisely on the "Redo" element
    Then the number of "text block" elements should be more than the remembered "text blocks before"
    And I remember the number of "text block" elements as "text blocks with one added"

    When I click precisely on the "last text block" element
    And I click precisely on the "Duplicate block" element
    Then the number of "text block" elements should be more than the remembered "text blocks with one added"
    When I click precisely on the "last text block" element
    And I click precisely on the "Delete block" element
    Then the number of "text block" elements should equal the remembered "text blocks with one added"

    # Named only now, so Undo above can't be undoing the name instead.
    When I click precisely on the "Content settings toggle" element
    And I fill in the "Page Name" input field with a unique test title
    And I type "Velstar Test block text" into the "last text block editor" rich text editor
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element
    Then the "success toast" should contain the text "Content successfully saved!"
    When I reload the page
    And I wait for the page to settle
    # No block count here: a new page's default "Edit me!" content isn't a
    # text-component in the editor until it has been saved, so the count
    # after a reload is one higher than while editing (seen 2026-11-25).
    Then the "Page Name" input field should have the stored content title
    And the "last text block" should contain the text "Velstar Test block text"

    When I click precisely on the "Back to list" element
    And I delete the content row containing the stored content title

  Scenario: An existing page opens in the editor with its blocks, and can be previewed and exported
    Given I start monitoring console errors, ignoring messages matching "requestStorageAccess"
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "first item link" element
    And I wait for the page to settle
    Then I should see at least 1 "editor block" displayed
    And the "Add blocks panel" should be displayed
    When I click precisely on the "Preview content" element
    Then the "Preview mobile" should be displayed
    And the "Preview desktop" should be displayed
    When I click precisely on the "Preview content" element
    And I click on the "Export content" button, remembering the downloaded file as "content export"
    Then the remembered "content export" download should not be empty
    And the remembered "content export" download should start with the text "{"
    And there should be no unexpected console errors

  # CKEditor 34 -> 49. Bold goes through the editor's command layer, so a
  # surviving <strong> proves more than plain text input.
  @mutates-admin-data
  Scenario: Text typed in bold into a Category description is saved as bold text
    Given I require a staging admin for this scenario
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I click precisely on the "Add Category" element
    And I fill in the "Heading" input field with a unique test title
    And I type "Velstar Test bold description" in bold into the "Category Description editor" rich text editor
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Category successfully added!"

    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I click precisely on the "first item link" element
    And I wait for the page to settle
    Then the "Category Description editor" should contain the text "Velstar Test bold description"
    And the "Category Description bold text" should contain the text "Velstar Test bold description"

    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  # ----------------------------------------------------------------- orders

  # Read-only: no status change or note is saved (both can email the
  # customer on a real order).
  Scenario: Opening the first order shows its full order view
    When I click precisely on the "Orders" element
    And I click precisely on the "first order link" element
    Then I should be redirected to the "order-detail" page
    And the "page heading" should contain the text "View Order"
    And the "Order Status section" should be displayed
    And the "Items section" should be displayed
    And the "Customer section" should be displayed
    And the "History section" should be displayed
    And the "Shipping section" should be displayed
    And the "Transactions section" should be displayed
    And the "Resend Confirmation Email" should be displayed
    And the "Update Order Status" should not be enabled
    When I click precisely on the "Add Note" element
    Then the "note field" should be displayed

  # The pick list is generated in the browser by @react-pdf, now a lazy chunk.
  Scenario: Downloading a pick list for an order produces a PDF
    When I click precisely on the "Orders" element
    And I click precisely on the "first order select" element
    Then the "pick list panel" should contain the text "Generate 1 Pick List"
    When I click on the "Download Pick List" button, remembering the downloaded file as "pick list"
    Then the remembered "pick list" download should not be empty
    And the remembered "pick list" download should start with the text "%PDF"

  Scenario: Exporting orders for a date range downloads an order CSV
    When I click precisely on the "Orders" element
    And I click precisely on the "Export Order Data" element
    Then the "Download order export" should not be enabled
    When I fill in the "Export start date" input field with "01/01/2020"
    And I fill in the "Export end date" input field with "31/12/2026"
    And I press the Escape key
    And I click on the "Download order export" button, remembering the downloaded file as "order export"
    Then the remembered "order export" download should be named "order_export_2020-01-01_to_2026-12-31.csv"
    And the remembered "order export" download should start with the text "email,placedByEmail,reference,customerReference,currency"

  Scenario: The Create Order screen opens its customer picker
    Given I start monitoring console errors, ignoring messages matching "requestStorageAccess"
    When I click precisely on the "Orders" element
    And I click precisely on the "Create Order" element
    Then I should be redirected to the "orders-create" page
    And the "Product Name search" should be displayed
    And the "Promotion Code" should be displayed
    When I click precisely on the "Change Customer" element
    Then the "select customer modal" should be displayed
    When I click precisely on the "Close select customer" element
    Then the "select customer modal" should not be visible
    And there should be no unexpected console errors

  # ------------------------------------------------------ exports and import

  Scenario Outline: Exporting <export> from the <list> list downloads a real CSV
    When I am on the "<page id>" page
    And I wait for the page to settle
    And I click on the "<button>" button, remembering the downloaded file as "export"
    Then the remembered "export" download should be named "<file>"
    And the remembered "export" download should start with the text "<header start>"

    Examples:
      | export          | list       | page id          | button                   | file                       | header start                    |
      | categories      | Categories | categories       | Export Category Data     | category_export.csv        | identifier,heading,status       |
      | redirects       | Redirects  | redirects        | Export Redirect Data     | redirect_export.csv        | fromUrl,toUrl,code,partialMatch |
      | attributes      | Attributes | attributes       | Export Attribute Data    | attribute_export.csv       | code,label,description,locale   |
      | users           | Users      | users-export     | Export Users             | user_export.csv            | email,customerGroup,roles       |
      | addresses       | Users      | users-export     | Export Addresses         | address_export.csv         | userEmail,addressType           |
      | locations       | Locations  | locations-export | Export Locations         | location_export.csv        | slug,name,locationStatus        |
      | location types  | Locations  | locations-export | Export Location Types    | location_type_export.csv   | location,types                  |
      | location features | Locations | locations-export | Export Location Features | location_feature_export.csv | location,features             |

  # The CSV goes up as multipart/form-data through fetch (was Axios); the
  # import then runs on a worker, typically well under a minute.
  @mutates-admin-data
  Scenario: Importing a redirect CSV creates the redirect, which can then be deleted
    Given I require a staging admin for this scenario
    When I click precisely on the "Configuration" element
    And I click precisely on the "Redirects" element
    And I click precisely on the "Import Redirect Data" element
    Then I should be redirected to the "redirects-import" page
    When I upload the "velstar-test-redirect-import.csv" file to the "CSV file" input
    And I click precisely on the "Upload File" element
    Then the "success toast" should contain the text "Redirect data successfully uploaded"

    # Upload lands on the import's own page (/redirects/import/<id>), which
    # has no way back to the list.
    When I am on the "redirects" page
    And I reload the page until the "imported redirect" contains the text "/velstar-test-import-redirect", for up to 120 seconds
    And I click precisely on the "imported redirect" element
    And I wait for the page to settle
    And I click precisely on the "Delete Redirect" element
    And I click precisely on the "Confirm Delete Redirect" element
    Then the "success toast" should be displayed

  # ------------------------------------------------------------------ lists

  Scenario: Paging through the product list, changing rows per page and toggling a column
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I wait for the page to settle
    Then the "active page" should equal text "1"
    When I click precisely on the "next page" element
    And I wait for the page to settle
    Then the "active page" should equal text "2"
    And I should see at least 25 "table row" displayed
    When I select the "50" option from the "rows per page" dropdown
    And I wait for the page to settle
    Then I should see at least 26 "table row" displayed
    When I click precisely on the "Manage Columns" element
    And I click precisely on the "Total Inventory column toggle" element
    Then the "Total Inventory column header" should be displayed

  Scenario: Sorting the category list by name, then reversing it
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I wait for the page to settle
    Then clicking the "category name header" column header twice should reverse the order of the "category name links" cells

  # ------------------------------------------------- settings and modals

  Scenario Outline: The <tab> Settings tab shows its own settings
    When I click precisely on the "Configuration" element
    And I click precisely on the "Settings" element
    And I click precisely on the "<tab> tab" element
    Then the "selected settings panel" should contain the text "<label>"

    Examples:
      | tab               | label                                         |
      | Uploads           | Types                                         |
      | Categories        | Available Template Types                      |
      | Products          | Availability                                  |
      | Content Elements  | Content Element Areas                         |
      | Sitemaps          | Sub Url                                       |
      | Utilities         | Key Category Label                            |
      | Notification      | Notification Email address(s)                 |
      | Invoice           | Invoice Payment Confirmation Email Addresses  |
      | Locations         | Features                                      |
      | Orders            | Order Confirmation BCC Addresses              |
      | Shipping          | Types                                         |
      | Customer Groups   | Default Customer Group for Guests             |
      | User Groups       | Default User Group for Guests                 |
      | Users             | Types                                         |
      | User registration | Admin email address(s)                        |
      | Recaptcha         | Enable validation                             |

  Scenario: The first customer group opens its own detail page
    When I am on the "customer-groups" page
    And I click precisely on the "first item link" element
    Then I should be redirected to the "customer-group-detail" page
    And the "Customer Group Name" should be displayed

  # Bootstrap's modal JS is gone; every product modal must still open and
  # close. Closed modals stay in the DOM hidden, hence "not be visible".
  Scenario: The product Duplicate and Delete modals open and close
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I click precisely on the "first item link" element
    And I wait for the page to settle
    When I click precisely on the "Duplicate Product" element
    Then the "duplicate product modal" should be displayed
    When I click precisely on the "Close duplicate product" element
    Then the "duplicate product modal" should not be visible
    When I click precisely on the "Delete Product" element
    Then the "delete product modal" should be displayed
    When I click precisely on the "Close delete product" element
    Then the "delete product modal" should not be visible
    # "Manage Menu Item Relations" isn't checked: on Carbon it opens nothing
    # and sends no request on BOTH staging (React 16) and release (seen
    # 2026-11-25) - a pre-existing dead button, not part of this upgrade.

  # Auth is now a fetch Authorization header from localStorage: logging out
  # must clear it, so a protected route bounces back to login.
  Scenario: Logging out returns to the login page and protected pages stay locked
    When I click precisely on the "Orders" element
    And I remember the current URL path as "orders path"
    And I click precisely on the "Logout" element
    Then I should be redirected to the "login" page
    When I navigate directly to the remembered path "orders path"
    Then I should eventually be redirected to the "login" page
