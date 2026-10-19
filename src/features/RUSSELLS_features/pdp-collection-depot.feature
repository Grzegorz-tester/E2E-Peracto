@regression
Feature: PDP collection depot picker

  # Covers the PDP's "Collection" section - before any depot is chosen it
  # shows "Set your local depot"; selecting one from the slide-in panel
  # changes it to "Change" and shows the depot's name.

  Scenario: User can search for and select a local collection depot
    Given I navigate directly to the path "/products/roller-for-cnh-nh-92087109"
    And I click on the "Accept cookies" button if present
    Then the "Local depot button" should contain the text "Set your local depot"

    When I click on the "Local depot button" button
    Then the "Collection dialog" should be displayed
    When I fill in the "Depot search input" input field with "York"
    And I click on the "Depot search button" button
    And I click on the "Depot result card" button

    Then the "Local depot button" should contain the text "Change"
