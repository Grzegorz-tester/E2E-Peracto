@regression
Feature: Header search drawer

  # Ported from Insinkerator_EU's search-drawer.feature. The drawer is an
  # Algolia-backed autocomplete panel present on every page: default
  # (recommended products) state, closing it (needs a real
  # mousedown-pause-mouseup gesture, not a plain click - see
  # search-drawer.ts), live as-you-type results, and submitting to the full
  # /search results page.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

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
    And the "search drawer recommended products" should be displayed

    When I submit the search drawer for "sink"
    Then I should be redirected to the "search-results" page
    And the "search hits heading" should be displayed
    And the "search result names" should all contain the text "sink"

  # A fresh browser context (new scenario, new Background) has no search
  # history yet, so this starts from a genuinely empty state rather than
  # relying on a previous scenario's leftovers.
  #
  # CONFIRMED SITE BUG (live, 2026-08-19): submitting one search records TWO
  # recent-search entries - the real query, and a second, blank one linking
  # to "/search?q=" with no visible text. Asserting on the first (most
  # recent) entry specifically sidesteps that rather than assuming an exact
  # count of history entries.
  Scenario: A submitted search is remembered as a recent search, and Clear History removes it
    When I click on the "search drawer open button" button
    Then the "search drawer" should be displayed
    And the "search drawer input" should be displayed
    And the "search drawer no recent searches message" should be displayed

    When I fill in the "search drawer input" input field with "sink"
    Then the "search drawer results" should all contain the text "sink"
    When I submit the search drawer for "sink"

    When I am on the "home" page
    And I click on the "search drawer open button" button
    Then the "search drawer recent search links" should contain the text "sink"

    When I click on the "search drawer clear history button" button
    Then the "search drawer no recent searches message" should be displayed
