@regression
Feature: Branch Finder

  # Covers the manual test plan's "Branch Finder" suite (8 cases).
  # Confirmed live (2026-08-21): the page has a Google Places Autocomplete
  # search box ("Search by postcode, town or city") at the top, a
  # "View all branches" anchor link, an A-Z filter bar, and a plain list of
  # 14 real branch links (/branches/{slug}) below. No separate detail
  # content was explored beyond confirming the link itself resolves to a
  # branch-specific route - "select branch -> detail page" is checked via
  # URL, not page content, to stay resilient to that page's own layout.

  Background:
    Given I am on the "branches" page

  Scenario: Branch Finder and All Branches sections both render
    Then the "Branch Finder heading" should be displayed
    And the "All Branches heading" should be displayed
    And the "branch list item" should be displayed

  Scenario: "View all branches" scrolls to the full branch list
    When I click on the "View all branches link" element
    Then the current URL should contain "#all-branches"

  Scenario: Selecting a branch from the list navigates to its own detail page
    When I click on the "1st" "branch list item" element
    Then the current URL should contain "/branches/"

  Scenario Outline: Branches can be filtered by an alphabet letter
    When I click on the "<letter> filter button" element
    Then the "branch list item" should be displayed

    Examples:
      | letter |
      | A      |
      | M      |
      | All    |

  # Google Places Autocomplete's own suggestion list is live, third-party
  # data - not asserting a SPECIFIC closest branch, just that searching a
  # real town surfaces a suggestion and selecting it doesn't break the page
  # (the branch list stays populated rather than erroring/emptying).
  Scenario: Searching by town shows live suggestions and selecting one keeps the branch list working
    When I fill in the "branch search input" input field with "Manchester"
    Then the "branch search suggestion" should be displayed
    When I click on the "1st" "branch search suggestion" element
    Then the "branch list item" should be displayed
