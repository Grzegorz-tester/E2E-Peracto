@regression
Feature: Depot Finder

  # Covers the standalone /depot-finder store locator - distinct from the
  # PDP's own "Collection" depot picker (see pdp-collection-depot.feature),
  # a different component with its own separate search. The map-pin-count
  # check from the source suite is skipped here: it has no data-testid at
  # all and relies on a fragile bounding-box heuristic, flagged as a TODO
  # in the source suite itself rather than a reliable check worth porting.

  Background:
    Given I navigate directly to the path "/depot-finder"
    And I click on the "Accept cookies" button if present
    And the "Depot Finder heading" should be displayed

  @smoke
  Scenario: User can browse all depots and reach a depot detail page
    Then the "All Depots heading" should be displayed
    And the "Depot link" should be displayed

    When I remember the text of "Depot link" as "depot name"
    And I click on the "1st" "Depot link" element
    Then I should be redirected to the "depot-detail" page
    And the "Branch heading" text should equal the remembered "depot name"
    And the "Branch address" should be displayed
    And the "Branch telephone" should be displayed
    And the "Branch email" should be displayed
    And the "Branch opening hours Monday" should be displayed
    And the "Branch get directions" should have attribute "href" containing "google.com/maps/dir"

    When I click on the "Branch back to search" element
    Then I should be redirected to the "depot-finder" page

  Scenario: User can search a location and reach a result
    When I fill in the "Depot Finder search input" input field with "York"
    And I press Enter in the "Depot Finder search input" input field
    Then the "Depot Finder search result" should be displayed

    When I click on the "1st" "Depot Finder search result" element
    Then I should be redirected to the "depot-detail" page
    And the "Branch heading" should be displayed
