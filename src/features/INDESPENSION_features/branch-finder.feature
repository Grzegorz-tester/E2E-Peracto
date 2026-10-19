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

  # The map is what breaks on this page, not the headings or list, which is
  # why every other scenario here kept passing. Confirmed live (staging,
  # 2026-09-29): the map area is blank for ~10s, the Google Map draws
  # (.gm-style), then ~1s later Google replaces it with its own "Oops!
  # Something went wrong" overlay (.gm-err-container) because of
  # RefererNotAllowedMapError (see the town-search scenario below). Waits for
  # the map, then watches for the error overlay long enough to catch the swap.
  Scenario: The branch map loads without a Google Maps error
    Then the "branch map" should be displayed within "30" seconds
    And the "branch map error" should not appear within "10" seconds

  Scenario: "View all branches" scrolls to the full branch list
    When I click on the "View all branches link" element
    Then the "All Branches heading" should be scrolled into view

  Scenario: Selecting a branch from the list navigates to its own detail page
    When I click on the "1st" "branch list item" element
    Then the current URL should contain "/branches/"

  Scenario Outline: Branches can be filtered by the "<letter>" alphabet letter
    When I click on the "<letter> filter button" element
    Then the "branch list item" should be displayed

    Examples:
      | letter |
      | A      |
      | M      |
      | All    |

  # CONFIRMED SITE CONFIG ISSUE (live, staging, 2026-09-29): Google Maps
  # rejects the staging domain with RefererNotAllowedMapError ("Your site URL
  # to be authorized: https://staging.indespension.pub/branches"), so the
  # map shows "Oops! Something went wrong" and autocomplete never offers a
  # suggestion. Expected to stay red until the staging domain is added to
  # the Maps API key's allowed referrers. The search input also no longer
  # carries the react-google-places id, so it's matched by placeholder.
  #
  # Google Places Autocomplete's own suggestion list is live, third-party
  # data - not asserting a SPECIFIC closest branch, just that searching a
  # real town surfaces a suggestion and selecting it doesn't break the page
  # (the branch list stays populated rather than erroring/emptying).
  @not-on-production
  Scenario: Searching by town shows live suggestions and selecting one keeps the branch list working
    When I fill in the "branch search input" input field with "Manchester"
    Then the "branch search suggestion" should be displayed
    When I click on the "1st" "branch search suggestion" element
    Then the "branch list item" should be displayed


  # Production's branch search is type-and-submit, not autocomplete
  # (confirmed live 2026-09-29): its Maps script loads only the "core"
  # library, no Places, so there are never live suggestions. Submitting
  # geocodes the town (GeocodeService.Search "Manchester, UK") and moves the
  # map; the branch list itself is unchanged. The autocomplete scenario
  # above is staging's newer build and is excluded on production.
  @production-only
  Scenario: Searching by town on production geocodes it and keeps the map and branch list working
    When I fill in the "branch search input" input field with "Manchester"
    And I click on the "branch search button" button
    Then the "branch map" should be displayed within "30" seconds
    And the "branch map error" should not appear within "10" seconds
    And the "branch list item" should be displayed
