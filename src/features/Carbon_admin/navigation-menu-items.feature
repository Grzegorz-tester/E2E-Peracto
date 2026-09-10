@regression @mutates-admin-data
Feature: Adding A Direct Link To The Orphaned Pages Menu

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - completes Navigation menu item coverage started in
  # content-creation.feature: that file covers the Page/Article item types
  # (via the async "Select Item" search, which finds an EXISTING page/
  # article by title). This covers "Direct Link", the other item type
  # confirmed live to need its own distinct fields instead - Link Text,
  # Link Location (an arbitrary URL, not a search) - and a "Link type"
  # react-select that defaults to "External" without needing to be
  # touched. Confirmed live on Andy Thornton (an independent tenant) that
  # both fields exist identically. Was already tagged @mutates-admin-data
  # but was missing the matching "I require a staging admin" runtime
  # guard - added on promotion, same double-layer pattern as every other
  # write scenario in this suite (see src/index.ts's @mutates-admin-data
  # comment for why both exist independently).
  #
  # Reuses the exact same generic "unique test title" / "the remembered
  # ... should appear in ..." / "remove the stored content title" steps
  # content-creation.feature already established for this - confirmed
  # live none of them are actually Page/Article-specific, just built
  # around a "content title" stashed in globalVariables.

  Scenario: Adding a Direct Link item to the Orphaned Pages menu
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Navigation" element
    And I click precisely on the "Orphaned pages" element
    And I click precisely on the "Add Item" element
    And I select the "Direct Link" option from the "Navigation Item Type" react-select
    And I fill in the "Link Text" input field with a unique test title
    And I fill in the "Link Location" input field with "/"
    And I click precisely on the "Submit" element
    Then the "success toast" should contain the text "Item successfully added!"
    And the remembered "content title" should appear in the "menu item title" element

    When I remove the stored content title from the "menu item row" navigation menu
