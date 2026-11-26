@regression
Feature: Header search

  # New coverage (2026-10-05). The header search is Algolia autocomplete:
  # typing shows a dropdown grouped into PRODUCTS / CATEGORIES /
  # ARTICLES & PAGES. A separate /search?q= results page also exists.

  Scenario: Typing a product name shows matching products and categories
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "plywood"
    Then the "search results" should be displayed
    And the "first search result" should contain the text "Plywood"
    And the "search categories heading" should be displayed
    And the "first search category result" should contain the text "Plywood"


  @smoke
  Scenario: Clicking a product suggestion opens its product page
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "Marine Plywood"
    And I click on the "first search result" element, retrying until redirected to the "pdp" page
    Then the "product title" should contain the text "Marine Plywood"


  Scenario: Clicking a category suggestion opens its listing
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "plywood"
    And I click on the "first search category result" element, retrying until redirected to the "plp" page
    Then the "PLP title" should contain the text "Plywood"


  Scenario: A search with no matches says so
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "zzqxvelstarnomatch"
    Then the "search no results" should be displayed


  Scenario: Clearing the search box empties it
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "plywood"
    And I click on the "search clear button" element
    Then the "header search input" should equal the value ""


  # An early exploration (2026-10-05) concluded Enter/the magnifier did
  # nothing - RETRACTED 2026-10-06: that was the hydration race (typing
  # before React hydrates the input). With the settle step both work.
  Scenario Outline: Submitting the header search via <method> opens the search results page
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "plywood"
    And the "search results" should be displayed
    And <action>
    Then I should eventually be redirected to the "search" page
    Examples:
      | method         | action                                                |
      | Enter          | I press Enter in the "header search input" input field |
      | the magnifier  | I click on the "search magnifier" element              |


  @smoke
  Scenario: Search results page lists matching products
    Given I navigate directly to the path "/search?q=plywood"
    And I wait for the page to settle
    Then the "category page title" should contain the text "plywood"
    And the "PLP hit count" should be displayed
    And the "product card" should be displayed
    And the "PLP first product card title" should contain the text "Plywood"


  # Smoke case 201 (added 2026-10-23).
  @smoke
  Scenario: Searching by SKU suggests the matching product
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "310239"
    And I wait for the search results to update
    Then the "first search result" should contain the text "Marine Plywood"
    When I click on the "first search result" element, retrying until redirected to the "pdp" page
    Then the "product SKU" should contain the text "310239"


  # BEN-389 (Benchmarx Next.js 15, added 2026-11-22): search ignored ?q= and
  # listed every product. Two terms must give different results, the term
  # must survive a reload and page 2, and nonsense must find nothing.
  Scenario: The search results page honours the search term
    Given I navigate directly to the path "/search?q=plywood"
    And I wait for the page to settle
    Then the "category page title" should contain the text "plywood"
    And I remember the text of "PLP hit count" as "plywood count"
    When I navigate directly to the path "/search?q=cement"
    And I wait for the page to settle
    Then the "category page title" should contain the text "cement"
    And the "PLP first product card title" should contain the text "Cement"
    And the "PLP hit count" text should not equal the remembered "plywood count"
    When I reload the page
    And I wait for the page to settle
    Then the "category page title" should contain the text "cement"
    And the "PLP first product card title" should contain the text "Cement"


  Scenario: Page 2 of search results keeps the search term
    Given I navigate directly to the path "/search?q=plywood"
    And I wait for the page to settle
    And I remember the text of "PLP first product card title" as "first page product"
    When I navigate directly to the path "/search?q=plywood&page=2"
    And I wait for the page to settle
    Then the "category page title" should contain the text "plywood"
    And the "PLP hit count" should contain the text "of 38 products"
    And the "PLP first product card title" text should not equal the remembered "first page product"


  Scenario: A search for nonsense finds nothing
    Given I navigate directly to the path "/search?q=zzzqqqx"
    And I wait for the page to settle
    Then the "category page title" should contain the text "Sorry, we can't find any results for"
    And the "product card" should not be displayed

