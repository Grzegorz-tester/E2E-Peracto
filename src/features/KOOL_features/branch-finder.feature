@smoke
@regression
Feature: Branch Finder

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > Branch
  # Finder" (case 540).
  #
  # The "react-google-places-autocomplete" listbox/option selectors and
  # "branch result" mapping in branches.json are best-effort guesses based
  # on that library's typical DOM, not yet confirmed live - verify before
  # trusting this scenario.

  Scenario: Branch Finder - Search returns closest branches
    Given I am on the "branches" page
    When I fill in the "branch search" input field with "Glasgow"
    And I wait for the search results to update
    And I click on the "1st" "address autocomplete options" element
    Then the "branch result" should be displayed
