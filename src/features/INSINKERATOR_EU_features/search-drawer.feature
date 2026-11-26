@regression
Feature: Header search drawer

  # Ported from P3Playwright's insinkerator_eu/tests/navigation/
  # search-drawer.test.ts. The drawer is an Algolia-backed autocomplete
  # panel present on every page: default (recommended products) state,
  # closing it (needs a real mousedown-pause-mouseup gesture, not a plain
  # click - see search-drawer.ts), live as-you-type results, and submitting
  # to the full /search results page.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present

  @smoke
  Scenario: User can open the drawer, close it, search live, and reach the results page
    When I click on the "search drawer open button" button
    Then the "search drawer" should be displayed
    And the "search drawer input" should be displayed
    And the "search drawer recommended products" should be displayed

    When I close the "search drawer" using a mouse-hold gesture on the "search drawer close button"
    Then the "search drawer" should not be displayed

    When I click on the "search drawer open button" button
    And I fill in the "search drawer input" input field with "sink"
    Then the "search drawer results" should all contain the text "sink"

    When I submit the search drawer for "sink"
    Then I should be redirected to the "search-results" page
    And the "search hits heading" should be displayed
    And the "search result names" should all contain the text "sink"

  # Covers Benchmarx BEN-389 (Next 15: /search?q=<term> ignored the term and
  # listed every product), re-checked on this site 2026-11-26. The scenario
  # above only reaches the results page through the drawer; this loads the
  # URL directly and reloads it. Live 2026-11-26: 'Showing results for
  # "nickel" (12)'. The country modal shows again after a reload.
  Scenario: Opening and reloading a search URL keeps the search term
    Given I navigate directly to the path "/search?q=nickel"
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    Then the "search hits heading" should contain the text "Showing results for "nickel""
    And the "product card" should be displayed
    When I reload the page
    And I click on the "Select Portugal" button if present
    Then the "search hits heading" should contain the text "Showing results for "nickel""
    And the "product card" should be displayed
