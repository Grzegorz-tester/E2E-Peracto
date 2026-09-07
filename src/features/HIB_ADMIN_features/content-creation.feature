@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to HIB, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA's own content-creation.feature: this WRITES real
  # data (creates a page/article, then adds and removes a menu item),
  # which per CLAUDE.md's "Staging vs production rules" is only safe on a
  # staging admin. HIB has no production admin env in this repo today,
  # but the shared Carbon_admin folder IS reused by tenants that DO have
  # one - so this deliberately lives in its own HIB-only feature path.
  #
  # CONFIRMED (live, HIB Admin staging, 2026-08-31): the Orphaned Pages
  # menu genuinely exists here (53 real entries, Add Item present) - an
  # earlier pass over this tenant reported the Save button as broken and
  # never got this far, which turned out to be a false negative (see
  # below), not a real gap.
  #
  # ONE real per-tenant difference from MIPA: the save control is a
  # two-step DROPDOWN, not a single icon button - clicking
  # `content-dropdown-save` reveals "Save" (`content-save`) and "Save and
  # Index" (`content-save-index`) options, and only clicking the former
  # actually persists (same shape already confirmed on JTDove/Andy
  # Thornton). A single click on the toggle alone does nothing visible
  # (no toast, no request) and can look like a broken Save button if you
  # stop there - it isn't; it just needs the second click. Both steps use
  # the existing generic "I click precisely on the ... element" step with
  # two mapping keys ("Save dropdown" then "Save content") - no new
  # TypeScript needed.

  Scenario: Creating a new page adds it to the Orphaned Pages menu
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "Create New Page" element
    And I fill in the "Page Name" input field with a unique test title
    And I click precisely on the "Save dropdown" element
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
    And I click precisely on the "Save dropdown" element
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
