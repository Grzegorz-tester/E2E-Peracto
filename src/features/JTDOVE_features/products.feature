@regression
Feature: Product Listing Page (PLP)

  # Full rewrite (2026-10-05) - the previous version pointed at HIB's
  # "bathroom-cabinets"/"bathroom-mirrors" pages and an "Apex" filter, and
  # asserted nothing. Rebuilt against real JT Dove listings:
  # - Plywood (/category/timber-sheet/sheet-material/plywood): 11 products,
  #   one page, so a price sort can be checked across every card.
  # - Special Offers: 500+ products, paginated, with Top Level Category /
  #   Category / Offer Type filters.
  # Prices on JT Dove are shown to guests (ex. VAT by default).

  @smoke
  Scenario: PLP loads with products, prices and add-to-basket buttons
    Given I am on the "plywood" page
    And I wait for the page to settle
    Then the "PLP title" should contain the text "Plywood"
    And the "PLP hit count" should contain the text "products"
    And the "breadcrumb" should be displayed
    And the "PLP first product card title" should be displayed
    And the "PLP first product card price" should contain the text "£"
    And the "PLP first product card delivery" should be displayed


  @smoke
  Scenario: Clicking a product on the PLP navigates to its PDP
    Given I am on the "plywood" page
    And I wait for the page to settle
    When I remember the text of "PLP first product card title" as "product name"
    And I click on the "PLP first product card view product" element, retrying until redirected to the "pdp" page
    Then the "product title" should contain the remembered "product name"


  # KNOWN SITE/DATA ISSUE (confirmed live 2026-10-06, both directions):
  # "9XB TEST Product" (shown as £19.99) sorts as if it were ~£12 - between
  # £9.69 and £12.00 ascending, and after £12.00 descending - so the price
  # the Algolia sort uses doesn't match the price the card displays.
  # Expected to stay red until that product's indexed price matches (or the
  # staging test product is removed from Plywood).
  Scenario Outline: Sorting by price <direction> orders every card's price
    Given I am on the "plywood" page
    And I wait for the page to settle
    And the "PLP first product card price" should be displayed
    When I click on the "Sort By" element
    And I click on the "<option>" element
    And I wait for the search results to update
    Then the "product card price" prices should be sorted in "<order>" order
    Examples:
      | direction    | option                   | order      |
      | low to high  | Price low to high option | ascending  |
      | high to low  | Price high to low option | descending |


  @smoke
  Scenario: Applying a filter narrows the results
    Given I am on the "special-offers" page
    And I wait for the page to settle
    And I remember the text of "PLP hit count" as "unfiltered count"
    When I click on the "Filter" element
    And I click on the "first facet checkbox" element
    And I wait for the search results to update
    And I click on the "filter drawer close button" element if present
    # BEN-402 (Benchmarx Next.js 15): closing the drawer dropped the filter
    # about a second later, so wait before checking it stuck.
    And I wait for the search results to update
    Then the "PLP hit count" text should not equal the remembered "unfiltered count"
    And the "Filter" should not contain the text "(0)"


  # Smoke case 199 (added 2026-10-23).
  @smoke
  Scenario: Clearing the filters brings back the full results
    Given I am on the "special-offers" page
    And I wait for the page to settle
    And I remember the text of "PLP hit count" as "unfiltered count"
    When I click on the "Filter" element
    And I click on the "first facet checkbox" element
    And I wait for the search results to update
    Then the "PLP hit count" text should not equal the remembered "unfiltered count"
    # The drawer's own "Clear all": the page has a second one that the open
    # drawer covers.
    When I click on the "Clear all filters" button
    And I wait for the search results to update
    And I click on the "filter drawer close button" element if present
    Then the "PLP hit count" text should equal the remembered "unfiltered count"
    # Not asserted: after "Clear all" the Filter button still read "Filter (3)"
    # although the full results were back (seen 2026-10-23, unconfirmed,
    # raised with QA).


  @smoke
  Scenario: Pagination moves to the next page of results
    Given I am on the "special-offers" page
    And I wait for the page to settle
    And I remember the text of "PLP first product card title" as "first page product"
    When I click on the "PLP pagination next" element
    And I wait for the search results to update
    Then the "PLP first product card title" text should not equal the remembered "first page product"
    And the current URL should contain "page=2"


  @smoke
  Scenario: Adding to basket for delivery straight from the PLP
    Given I am on the "plywood" page
    And I wait for the page to settle
    When I click on the "PLP first product card delivery" element
    Then the "added to basket drawer" should be displayed within "15" seconds


  # Checks from the Benchmarx Next.js 15 upgrade bugs (BEN-379, added
  # 2026-11-22), so the JT Dove upgrade catches the same breakages.

  # BEN-400: Next.js 15 dropped the name sorts. Staging 2026-11-22 offers
  # Featured, Price low/high and Name A-Z/Z-A.
  Scenario Outline: The "<sort>" sort option is offered and can be chosen
    Given I am on the "special-offers" page
    And I wait for the page to settle
    When I click on the "Sort By" element
    And I click on the "<sort> option" element
    And I wait for the search results to update
    Then the "Sort By" should contain the text "<sort label>"
    And the "PLP first product card title" should be displayed
    Examples:
      | sort              | sort label          |
      | Featured          | Featured            |
      | Price low to high | Price - low to high |
      | Price high to low | Price - high to low |
      | Name A-Z          | Name - A-Z          |
      | Name Z-A          | Name - Z-A          |


  # BEN-401: Next.js 15 changed the page size. JT Dove shows 16 per page
  # ("16 of 517 products" on 2026-11-22).
  Scenario: A listing page shows 16 products per page
    Given I am on the "special-offers" page
    And I wait for the page to settle
    Then I should see "16" "product card" displayed
    And the "PLP hit count" should contain the text "16 of"


  # BEN-393: Next.js 15 ignored ?page= on a direct visit and showed page 1
  # again (searchParams handling). Clicking Next is covered above; this is
  # the server-rendered URL.
  Scenario: Opening page 2 of a listing directly shows the second page
    Given I am on the "special-offers" page
    And I wait for the page to settle
    And I remember the text of "PLP first product card title" as "first page product"
    When I navigate directly to the path "/category/Special-Offers?page=2"
    And I wait for the page to settle
    Then the "PLP first product card title" text should not equal the remembered "first page product"
    And the "PLP pagination" should be displayed
