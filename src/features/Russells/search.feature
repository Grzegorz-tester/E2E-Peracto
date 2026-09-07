@regression
Feature: Header search

  # Unlike Insinkerator's search DRAWER (opened by an icon), Russells'
  # desktop search is a plain, always-visible Algolia autocomplete input in
  # the header.

  @smoke
  Scenario: User can search live from the header and reach the results page
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search bar" input field with "bearing"
    And I wait for the search results to update
    Then the "search hit product name" should all contain the text "bearing"

    When I press Enter in the "Search bar" input field
    Then I should be redirected to the "search" page
    And the "hits heading" should be displayed
    And the "product card" should be displayed
