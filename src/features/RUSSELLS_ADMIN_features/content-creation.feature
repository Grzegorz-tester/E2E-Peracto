@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to Russells, not the shared Carbon_admin boilerplate suite -
  # same reasoning as MIPA's own content-creation.feature: this WRITES
  # real data (creates a page/article, then adds and removes a menu
  # item), which per CLAUDE.md's "Staging vs production rules" is only
  # safe on a staging admin. Russells has no production admin env in this
  # repo today, but the shared Carbon_admin folder IS reused by tenants
  # that DO have one (e.g. KOOL_ADMIN_PROD.env) - so this deliberately
  # lives in its own Russells-only feature path rather than the shared
  # folder.
  #
  # CONFIRMED (live, Russells Admin staging, 2026-08-31): behaves
  # identically to MIPA in every respect that matters here - content-name/
  # content-heading fields, slug auto-generates on blur, the Orphaned
  # Pages menu at /menus/orphaned_pages genuinely exists with real rows
  # (an earlier investigation of this tenant wrongly concluded it didn't -
  # that was a live-verification miss, not a real gap; re-confirmed here
  # directly by loading that URL and seeing real entries like "Forage
  # Harvester Parts", "Homepage", etc.), and the Add Item modal's
  # Navigation Item Type / async-search Select Item react-selects work
  # unmodified.
  #
  # ONE real per-tenant difference from MIPA: the content editor's save
  # control renders a `data-icon="floppy-disk"` SVG, not MIPA's
  # `data-icon="save"` - already reflected in this tenant's own
  # common.json's "Save content" key, so no step-definition change was
  # needed, just the right selector.

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
