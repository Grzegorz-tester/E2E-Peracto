@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to MIPA, not the shared Carbon_admin boilerplate suite - same
  # reasoning as product-management.feature and tasks.feature: this WRITES
  # real data (creates a page/article, then adds and removes a menu item),
  # which per CLAUDE.md's "Staging vs production rules" is only safe on a
  # staging admin. MIPA has no production admin env in this repo today, but
  # the shared Carbon_admin folder IS reused by tenants that DO have one
  # (e.g. KOOL_ADMIN_PROD.env) - so this deliberately lives in its own
  # MIPA-only feature path rather than the shared folder.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-08-30):
  # - Only ONE field needs filling - "Name" for a Page (content-name),
  #   "Heading" for an Article (content-heading) - the slug (content-slug)
  #   auto-generates from it on blur; a separate "Title" field exists but
  #   is genuinely optional, saving fine when left blank.
  # - The save control is an icon-only button (an SVG with
  #   data-icon="save", no data-testid) - "Save content" in common.json
  #   targets it via `button:has(svg[data-icon='save'])`.
  # - Saving raises a "Content successfully saved!" success toast and
  #   moves the URL from /content/edit/page/ (or .../article/) to
  #   .../<id> - reloading that URL afterwards still shows the same
  #   title, confirming it genuinely persisted server-side rather than
  #   just rendering optimistically.
  # - Configuration > Navigation > Orphaned pages > "Add Item" opens a
  #   modal with a "Navigation Item Type" react-select (Category/Page/
  #   Article/Article Category/Direct Link/Branch - the existing "...
  #   react-select" step handles this, since its options are already
  #   rendered), then a "Select Item" react-select that is an ASYNC
  #   SEARCH box (starts as "Enter text to begin searching.", not a
  #   pre-populated list) - typing the page/article's own title finds it.
  #   Submitting raises an "Item successfully added!" toast and the new
  #   row appears in the menu tree as "<title> (<slug>)".
  # - The menu can hold many real, unrelated existing items (confirmed
  #   live: 17 pre-existing rows on MIPA's Orphaned Pages menu today), so
  #   verifying/cleaning up must target the row matching OUR OWN title,
  #   never "the first row" or "the only row".
  # - The content editor (both Page and Article) renders full-screen with
  #   NO sidebar at all - confirmed live: none of the "nav-*" testids the
  #   rest of this suite clicks through exist on that page, only its own
  #   "navigate-back" (chevron-left) control, which returns to that
  #   content type's own list (/pages or /articles). Every other admin
  #   page (the list views, Navigation, Orphaned Pages) keeps the normal
  #   sidebar - "Back to list" is only needed once, straight after
  #   leaving the editor.
  # - Cleanup removes the menu item first (Remove Item -> confirm), then
  #   deletes the underlying Page/Article row itself (checkbox -> Delete
  #   Row -> confirm) - same order the data depends on, and the same
  #   "delete what you created" discipline as product-management.feature,
  #   so repeated regression runs don't pile up disposable pages/articles
  #   or menu items in MIPA's real site.

  Scenario: Creating a new page adds it to the Orphaned Pages menu
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "Create New Page" element
    And I fill in the "Page Name" input field with a unique test title
    And I click precisely on the "Save content" element
    Then the "success toast" should contain the text "Content successfully saved!"

    When I reload the page
    Then the "Page Name" input field should have the stored content title

    When I click precisely on the "Back to list" element
    And I click precisely on the "Configuration" element
    And I click precisely on the "Navigation" element
    And I click precisely on the "Orphaned pages" element
    And I click precisely on the "Add Item" element
    And I select the "Page" option from the "Navigation Item Type" react-select
    And I search for the stored content title in the "Select Item" react-select
    And I click precisely on the "Submit" element
    Then the "success toast" should contain the text "Item successfully added!"
    And the remembered "content title" should appear in the "menu item title" element

    When I remove the stored content title from the "menu item row" navigation menu
    And I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I delete the content row containing the stored content title

  Scenario: Creating a new article adds it to the Orphaned Pages menu
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Articles" element
    And I click precisely on the "Create New Article" element
    And I fill in the "Article Heading" input field with a unique test title
    And I click precisely on the "Save content" element
    Then the "success toast" should contain the text "Content successfully saved!"

    When I reload the page
    Then the "Article Heading" input field should have the stored content title

    When I click precisely on the "Back to list" element
    And I click precisely on the "Configuration" element
    And I click precisely on the "Navigation" element
    And I click precisely on the "Orphaned pages" element
    And I click precisely on the "Add Item" element
    And I select the "Article" option from the "Navigation Item Type" react-select
    And I search for the stored content title in the "Select Item" react-select
    And I click precisely on the "Submit" element
    Then the "success toast" should contain the text "Item successfully added!"
    And the remembered "content title" should appear in the "menu item title" element

    When I remove the stored content title from the "menu item row" navigation menu
    And I click precisely on the "Content" element
    And I click precisely on the "Articles" element
    And I delete the content row containing the stored content title
