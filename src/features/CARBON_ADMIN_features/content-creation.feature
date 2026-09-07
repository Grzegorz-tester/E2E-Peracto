@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to Carbon, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA_ADMIN_features/content-creation.feature: this WRITES
  # real data (creates a page/article, then adds and removes a menu item),
  # which per CLAUDE.md's "Staging vs production rules" is only safe on a
  # staging admin. Carbon has no production admin env in this repo today.
  #
  # CONFIRMED (live, Carbon Admin staging, 2026-08-31):
  # - Only ONE field needs filling - "Name" for a Page (content-name),
  #   same content-name/content-slug/content-title shape as MIPA's - slug
  #   auto-generates on blur.
  # - CARBON-SPECIFIC DIFFERENCE from MIPA: the Save control here is a
  #   two-step dropdown, not a single icon button - "Open save menu"
  #   (`content-dropdown-save`) must be clicked first to reveal "Save
  #   content" (`content-save`, a dropdown-item, invisible until then).
  #   Confirmed this dropdown genuinely works on Carbon (unlike
  #   PizzaExpressLive's identical-looking dropdown, which never opens -
  #   a real site bug there, not here).
  # - Saving raises the same "Content successfully saved!" success toast
  #   as MIPA and moves the URL to /content/edit/page/<id>.
  # - The content editor has no sidebar (same as MIPA) - "Back to list"
  #   (`navigate-back`) is needed once after leaving it, before any
  #   nav-based click works again.
  # - Configuration > Navigation > Orphaned Pages > Add Item, the
  #   Navigation Item Type / async-search Select Item react-selects, and
  #   the Remove Item / content-row cleanup flow all work identically to
  #   MIPA's - same underlying Peracto Admin product, no differences
  #   found here.

  Scenario: Creating a new page adds it to the Orphaned Pages menu
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "Create New Page" element
    And I fill in the "Page Name" input field with a unique test title
    And I click precisely on the "Open save menu" element
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
    And I click precisely on the "Open save menu" element
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
