@regression
Feature: Quick Parts Finder

  # Covers the cascading machine type -> brand -> model widget present on
  # category hub pages (e.g. /agriculture), submitting to /parts-finder - a
  # results page reusing the same Algolia PLP testids as a category PLP.
  # The widget's own selection is pure client-side state, not reflected in
  # the URL or a cookie.

  Background:
    Given I navigate directly to the path "/agriculture"
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: User can cascade machine type, brand and model and reach filtered results
    Then the "Machine type" should be enabled
    And the "Brand" should not be enabled
    And the "Model" should not be enabled
    And the "Search parts" should not be enabled

    When I open the "Machine type" command dialog
    And I select the "TRACTOR" option from the currently open command dialog
    Then the "Brand" should be enabled
    And the "Model" should be enabled
    And the "Search parts" should not be enabled

    When I open the "Brand" command dialog
    And I select the "New Holland" option from the currently open command dialog

    When I open the "Model" command dialog
    And I search for "TS100" in the currently open command dialog
    And I select the "New Holland - TS100" option from the currently open command dialog
    Then the "Search parts" should be enabled

    When I click on the "Search parts" button
    Then I should be redirected to the "parts-finder" page
    And the "hits heading" should be displayed
    And the "Results banner" should contain the text "Showing results for"
    And the "Results banner" should contain the text "Machine Type: TRACTOR"
    And the "Results banner" should contain the text "Brand: New Holland"
    And the "Results banner" should contain the text "Model: New Holland - TS100"

  Scenario: Searching for a model with no matches shows no results and keeps search disabled
    When I open the "Machine type" command dialog
    And I select the "TRACTOR" option from the currently open command dialog
    And I open the "Brand" command dialog
    And I select the "New Holland" option from the currently open command dialog

    When I open the "Model" command dialog
    And I search for "8360" in the currently open command dialog
    Then the "Parts Finder dialog" should contain the text "No results found."
    When I press the Escape key
    Then the "Search parts" should not be enabled

  Scenario: Change Vehicle does not reset the current selection
    When I open the "Machine type" command dialog
    And I select the "TRACTOR" option from the currently open command dialog
    And I open the "Brand" command dialog
    And I select the "New Holland" option from the currently open command dialog
    And I open the "Model" command dialog
    And I search for "TS100" in the currently open command dialog
    And I select the "New Holland - TS100" option from the currently open command dialog
    And I click on the "Search parts" button
    Then I should be redirected to the "parts-finder" page

    When I remember the text of "Machine type" as "machine type"
    And I remember the text of "Brand" as "brand"
    And I remember the text of "Model" as "model"
    And I click on the "Change Vehicle" button
    Then the "Machine type" text should equal the remembered "machine type"
    And the "Brand" text should equal the remembered "brand"
    And the "Model" text should equal the remembered "model"
