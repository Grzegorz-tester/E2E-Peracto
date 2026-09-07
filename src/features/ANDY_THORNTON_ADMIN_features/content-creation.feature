@regression
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Bespoke to Andy Thornton, not the shared Carbon_admin boilerplate
  # suite - same reasoning as MIPA's own content-creation.feature: this
  # WRITES real data (creates a page/article, then adds and removes a
  # menu item). Andy Thornton has no production admin env in this repo,
  # so this bespoke path is safe by construction.
  #
  # CONFIRMED (live, ANDY_THORNTON_ADMIN staging, 2026-08-31): mostly
  # identical to MIPA's own content-creation.feature - only the "Name"
  # (Page) / "Heading" (Article) field needs filling, slug auto-generates
  # on blur, the content editor has no sidebar at all (only its own
  # "navigate-back" control), and Configuration > Navigation > Orphaned
  # pages > Add Item offers the same Page/Article/etc react-select plus
  # an async-search "Select Item" react-select.
  #
  # ONE REAL DIFFERENCE FROM MIPA: the save icon
  # (`[data-testid='content-dropdown-save']`, data-icon="save") is a
  # DROPDOWN TOGGLE here, not a direct save action - clicking it only
  # reveals two links, "Save" (`content-save`) and "Save and Index"
  # (`content-save-index`); the actual save request only fires after
  # clicking "Save" itself. A single click on the icon (MIPA's own
  # pattern) silently does nothing here - no request, no toast. "Save
  # dropdown" (opens it) then "Save content" (the real action) are two
  # separate mapping keys/steps for exactly this reason - every other
  # tenant so far has had Save as one direct action.

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
