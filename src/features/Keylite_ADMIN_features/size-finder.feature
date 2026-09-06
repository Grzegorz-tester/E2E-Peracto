@regression
Feature: Size Finder

  # Bespoke to Keylite, not the shared Carbon_admin boilerplate suite - Size
  # Finder (nav-products-size-finder, under Products) is Keylite's own extra
  # tab and doesn't exist in the standard Peracto Admin nav every other
  # tenant has, so per CLAUDE.md this gets its own small project-specific
  # feature file rather than being added to the shared folder.
  #
  # CONFIRMED live 2026-09-06: the nav item exists and links to /size-finder.
  # Only the nav item and route were verified in this exploration pass, not
  # the page's own content/functionality - keep this scenario to a basic
  # "the tab opens its own page" check until that's explored further.

  Scenario: The Size Finder tab opens its own page
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Size Finder" element
    Then the current URL should contain "/size-finder"
