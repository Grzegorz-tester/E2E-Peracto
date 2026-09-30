@regression
Feature: Search results page

  # Built 2026-09-30 from a live inspection of staging. header.feature checks
  # the header search redirects to /search; this checks what the results
  # page actually shows (the query goes in as ?q=).

  Background:
    Given I am on the "home" page
    And I click on the "Allow all cookies" button if present


  Scenario: Searching for a known term lists matching products
    When I fill in the "Search products" input field with "chair"
    And I click on the "magnifier glass" element
    Then I should eventually be redirected to the "search" page
    And the current URL should contain "q=chair"
    And the "product card" should be displayed
    And the "no search results" should not be displayed


  Scenario: A search result opens its PDP
    When I fill in the "Search products" input field with "Vienna Stackable Side Chair"
    And I click on the "magnifier glass" element
    Then I should eventually be redirected to the "search" page
    When I click on the "first product card" element
    Then I should eventually be redirected to the "product" page
    And the "product name" should contain the text "Vienna"


  Scenario: Searching for a nonsense term shows the no-results state
    When I fill in the "Search products" input field with "zzzxxqqnotathing"
    And I click on the "magnifier glass" element
    Then I should eventually be redirected to the "search" page
    And the "no search results" should be displayed
    And the "product card" should not be displayed
