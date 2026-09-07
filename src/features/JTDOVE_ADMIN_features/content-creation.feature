@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to JTDove, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA_ADMIN_features/content-creation.feature: this WRITES
  # real data (creates a page/article, then adds and removes a menu item),
  # which per CLAUDE.md's "Staging vs production rules" is only safe on a
  # staging admin. JTDove has no production admin env in this repo today.
  #
  # CONFIRMED (live, JTDove staging, 2026-08-31): same field/slug/toast
  # shape as MIPA (Name for Pages, Heading for Articles, slug auto-
  # generates from it on blur, "Content successfully saved!" toast,
  # Configuration > Navigation > Orphaned Pages > Add Item modal with the
  # same Navigation Item Type / async-search Select Item react-selects).
  #
  # ONE REAL DIFFERENCE FROM MIPA - the Save control here is a DROPDOWN
  # toggle (`content-dropdown-save`), not a single icon-only button: it
  # must be opened first before `content-save` (the actual save action,
  # hidden inside the dropdown menu until then) becomes clickable at all.
  # Even once open, a plain "click precisely" (non-forced) on
  # `content-save` reliably failed - Playwright's own "receives events"
  # check never passed, the same class of overlay-interference this
  # framework already documents elsewhere (click.ts's top comment) -
  # while `force: true` (the "I click on the ... element" step, not
  # "click precisely") worked immediately every time. "Content Save
  # Toggle" (opens the dropdown) + "Save content" (now mapped straight to
  # `[data-testid='content-save']`, not MIPA's generic icon selector)
  # capture this two-step, force-needed shape.

  Scenario: Creating a new page adds it to the Orphaned Pages menu
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "Create New Page" element
    And I fill in the "Page Name" input field with a unique test title
    And I click precisely on the "Content Save Toggle" element
    And I click on the "Save content" element
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
    And I click precisely on the "Content Save Toggle" element
    And I click on the "Save content" element
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
