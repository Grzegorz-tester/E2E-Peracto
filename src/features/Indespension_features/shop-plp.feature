@regression
Feature: Shop PLP

  # Full rewrite - the previous version navigated to "bathroom-cabinets"/
  # "bathroom-mirrors", neither of which exists in this project's
  # pages.json (confirmed live: it crashed with a TypeError reading
  # `.route` of undefined) - pure HIB leftovers. "Used Trailers" is the one
  # category confirmed live to be a real, directly filterable/sortable
  # Algolia PLP (the other nav hubs - Trailers, Trailer Parts, Towbars -
  # are landing pages with sub-category tiles, not product grids). No
  # facet/filter control was found on this category (confirmed live), so
  # this covers sorting only.

  Background:
    Given I am on the "used-trailers" page

  Scenario: Sorting by price changes the listing order
    When I remember the text of "first product name" as "used trailers first product before sort"
    And I click on the "Sort By" dropdown
    And I click on the "Price low to high" element
    Then the "first product name" text should not equal the remembered "used trailers first product before sort"
