@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to Insinkerator, not the shared Carbon_admin boilerplate suite -
  # same reasoning as MIPA's own content-creation.feature: this WRITES real
  # data (creates a page/article, then adds and removes a menu item), which
  # per CLAUDE.md's "Staging vs production rules" is only safe on a staging
  # admin. Insinkerator has no production admin env in this repo today, but
  # the shared Carbon_admin folder IS reused by tenants that DO have one
  # (e.g. KOOL_ADMIN_PROD.env) - so this deliberately lives in its own
  # Insinkerator-only feature path rather than the shared folder.
  #
  # CONFIRMED (live, INSINKERATOR_ADMIN staging, 2026-08-31): structurally
  # identical to MIPA's flow - only field to fill is "Name" (content-name),
  # slug auto-generates on blur, saving raises "Content successfully
  # saved!" and moves the URL to .../<id>, and the same Orphaned Pages
  # Add Item flow (Navigation Item Type react-select with Category/Page/
  # Article/Article Category/Direct Link/Branch, async-search Select Item
  # react-select) works unmodified.
  #
  # CONFIRMED TENANT DIFFERENCE: the icon-only Save button uses
  # `data-icon="floppy-disk"` here, not `"save"` like MIPA - overridden in
  # this project's own common.json ("Save content" key), same kind of
  # per-tenant icon difference already found on Russells.
  #
  # CONFIRMED QUIRK: navigating directly to a content-editor URL by
  # page.goto (rather than clicking through Content > Pages > Create New
  # Page) renders an incomplete/empty page - same client-side-fetch quirk
  # already found on this tenant's Tasks list. Always reach the editor via
  # the nav clicks, as this scenario does.

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
