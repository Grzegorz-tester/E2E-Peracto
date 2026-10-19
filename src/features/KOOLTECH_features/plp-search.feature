@smoke
@regression
Feature: Product Listing Page (PLP) & Search

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > Product
  # Listing Page (PLP) & Search" (cases 532-536).

  Scenario: PLP loads with products displayed correctly
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    Then the "product card" should be displayed
    And the "product name" should be displayed
    And the "product price" should be displayed
    When I click on the "product name" element
    Then the current URL should contain "/products/"

  # 2026-09-28: moved from Air Conditioning to Chemicals - every AC unit is
  # F-Gas gated ("confirm your F Gas registration"), so that listing shows
  # no Add to basket at all, guest or logged-in (confirmed identical on
  # staging and release-2-19-0). Chemicals shows it for guests on both.
  Scenario: PLP - Add product to basket from listing
    Given I am on the "chemicals-plp" page
    And I click on the "Accept cookies" button if present
    When I slowly click on the "Add to basket" button
    And I wait for the basket update to complete
    And I am on the "basket" page
    Then the "no items message" should not be displayed

  # The exact refinement option names in "refinement filters" haven't been
  # confirmed live for this category - this exercises the 1st available
  # filter checkbox generically rather than a specific named one.
  #
  # CONFIRMED SITE/DATA DIVERGENCE (live, 2026-09-11): asserting on the
  # on-page "product card" count (as this scenario originally did) is
  # fragile across environments - staging's 1st facet option happens to
  # match fewer than a page size (count visibly drops), but production's
  # 1st option ("M Series", 93 matches) still exceeds the 20-per-page
  # display size, so the visible count never drops even though the filter
  # is genuinely applied. A URL-based check was tried instead, but "Clear
  # all" leaves an empty "refinementList[...]=" param behind rather than
  # removing the key outright, so "should not contain refinementList" would
  # still wrongly fail. The page count in "PLP page indicator" ("N of M")
  # changes with the real, current total regardless of the 20-per-page
  # display cap - confirmed live going 34 -> 5 -> 34 pages - so comparing
  # that indicator's text is robust to whichever facet happens to be first,
  # on any environment.
  Scenario: PLP - Apply filters and confirm results update
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    And I remember the text of "PLP page indicator" as "unfiltered page indicator"
    When I click on the "1st" "refinement filters" element
    Then the "PLP page indicator" text should not equal the remembered "unfiltered page indicator"
    When I click on the "Clear all" button
    Then the "PLP page indicator" text should equal the remembered "unfiltered page indicator"

  # Confirmed live (2026-09-10): this category paginates via a prev/next
  # chevron control plus an "N of M" indicator, sitting at the very bottom
  # of the results with no data-testid of its own - not a "Load more"/
  # accumulating button (a prior scenario here wrongly assumed that shape
  # and never found a matching control). Pagination REPLACES the visible
  # page of results rather than appending to them, so the real signal that
  # it worked is the indicator advancing, not the product-card count
  # changing (it stays at a fixed page size on every page).
  Scenario: PLP - Pagination moves to the next page
    Given I am on the "air-conditioning-plp" page
    And I click on the "Accept cookies" button if present
    Then the "PLP page indicator" should contain the text "1 of"
    When I click on the "PLP next page button" element
    Then the "PLP page indicator" should contain the text "2 of"

  Scenario Outline: Search - Search by SKU and product name - "<term>"
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "<term>"
    And I wait for the search results to update
    Then the "first search result" should be displayed
    When I click on the "first search result" element
    Then the current URL should contain "/products/"

    Examples:
      | term      |
      | JAV-1071  |
      | JAVAC     |
