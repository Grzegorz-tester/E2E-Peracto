@regression
Feature: Search results page

  # CONFIRMED live 2026-09-23: submitting the header search goes to
  # /search?q=<term> (not ?query=, which silently shows All Products),
  # rendering the same product-card grid as the PLP under an
  # "algolia-hits-heading" of 'Showing results for "<term>"'. The header
  # autocomplete dropdown is covered separately in header.feature; this
  # covers the full results page it leads to.

  Background:
    Given I am navigating the page as a "guest" user

  Scenario: Submitting a header search shows a results page of matching products
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I fill in the "header search bar" input field with "blind"
    And I press Enter in the "header search bar" input field
    Then I should be redirected to the "search" page
    And the current URL should contain "q=blind"
    And the "search results heading" should contain the text "blind"
    And the "search result card" should be displayed
    And the "search result name" should contain the text "Blind"
    When I click on the "1st" "search result link" element via JavaScript
    Then I should be redirected to the "pdp" page

  # Reached via the header search, not "I navigate directly to the path" -
  # that step URL-encodes the "?" (/search%3Fq=...), confirmed live.
  Scenario: A search with no matches shows the no-results guidance
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I fill in the "header search bar" input field with "zzqqxxnotaproduct"
    And I press Enter in the "header search bar" input field
    Then I should be redirected to the "search" page
    Then the "no results message" should contain the text "Sorry, we can't find any results for"
    And the "search result card" should not be displayed
