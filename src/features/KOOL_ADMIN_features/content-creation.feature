@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to KOOL, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA's content-creation.feature: this WRITES real data
  # (creates a page/article, then adds and removes a menu item), which
  # per CLAUDE.md's "Staging vs production rules" is only safe on a
  # staging admin. KOOL DOES have a production admin env in this repo
  # (KOOL_ADMIN_PROD.env), but that env's FEATURE_PATH only globs the
  # shared Carbon_admin folder, not this KOOL-only feature path - so
  # this scenario is inherently safe from running against KOOL's
  # production admin without needing any extra tag/guard.
  #
  # CONFIRMED (live, KOOL_ADMIN staging, 2026-08-31): identical shape to
  # MIPA in every respect checked:
  # - Only the "Heading" field (content-heading) needs filling for an
  #   Article; "Name" (content-name) for a Page - the slug auto-generates
  #   from it on blur.
  # - The save control is the same icon-only button
  #   (`button:has(svg[data-icon='save'])`).
  # - Saving raises the same "Content successfully saved!" success toast.
  # - Configuration > Navigation > Orphaned pages > "Add Item" opens the
  #   identical modal (Navigation Item Type: Category/Page/Article/
  #   Article Category/Direct Link/Branch; an async-search "Select Item").
  # - The content editor also has no sidebar here (same as MIPA) - "Back
  #   to list" (navigate-back) is needed once after leaving it.

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
