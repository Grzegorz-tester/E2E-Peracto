@regression
Feature: Homepage navigation

  # Shared across every Watco market (see CLAUDE.md's Peracto Admin
  # boilerplate section for the same "shared feature file, per-market
  # config" pattern) - confirmed live 2026-09-06 against staging-uk.
  # Every element key here resolves through that market's own
  # config/Watco_<region>_config mapping, so this file itself never
  # hardcodes locale-specific text or URLs (e.g. "first category link" is
  # positional - whichever category happens to be first in that market's
  # own nav - not the literal word "Floors").

  Scenario: The category navigation is visible and its first link leads to its own listing page
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    Then the "category navigation" should be displayed

    When I click on the "first category link" element
    Then I should be redirected to the "plp" page
    And the "product card" should be displayed
