@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to Indespension, not the shared Carbon_admin boilerplate suite
  # - same reasoning as MIPA_ADMIN_features/content-creation.feature and
  # tasks.feature: this WRITES real data (creates a page/article, then
  # adds and removes a menu item), which per CLAUDE.md's "Staging vs
  # production rules" is only safe on a staging admin. Indespension has
  # no production admin env in this repo today, but the shared
  # Carbon_admin folder IS reused by tenants that DO have one (e.g.
  # KOOL_ADMIN_PROD.env) - so this deliberately lives in its own
  # Indespension-only feature path rather than the shared folder.
  #
  # CONFIRMED (live, INDESPENSION_ADMIN staging, 2026-08-31) - identical
  # to MIPA in every respect checked:
  # - Only the "Name" (Page) / "Heading" (Article) field needs filling -
  #   the slug (content-slug) auto-generates from it on blur.
  # - The save control is an icon-only button with an SVG
  #   data-icon="save" (not "floppy-disk" like Russells - verified, not
  #   assumed).
  # - The content editor renders full-screen with no sidebar - "Back to
  #   list" (navigate-back) is needed once, straight after leaving it,
  #   same as MIPA.
  # - Configuration > Navigation > Orphaned pages genuinely exists here
  #   with real pre-existing rows (unlike Russells, whose Navigation list
  #   is completely empty) - "Add Item" opens the same modal shape
  #   (Navigation Item Type react-select, async-search Select Item
  #   react-select), raises the same "Item successfully added!" toast,
  #   and the new row appears in the menu tree the same way.
  # - Cleanup removes the menu item first (Remove Item -> confirm), then
  #   deletes the underlying Page/Article row (checkbox -> Delete Row ->
  #   confirm) - same order and discipline as MIPA's own feature, so
  #   repeated regression runs don't pile up disposable data.

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
