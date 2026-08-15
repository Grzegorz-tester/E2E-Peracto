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
