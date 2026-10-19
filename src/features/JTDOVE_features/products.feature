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

  Scenario: PLP loads with products, prices and add-to-basket buttons
    Given I am on the "plywood" page
    And I wait for the page to settle
    Then the "PLP title" should contain the text "Plywood"
    And the "PLP hit count" should contain the text "products"
    And the "breadcrumb" should be displayed
    And the "PLP first product card title" should be displayed
    And the "PLP first product card price" should contain the text "£"
    And the "PLP first product card delivery" should be displayed


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


  Scenario: Applying a filter narrows the results
    Given I am on the "special-offers" page
    And I wait for the page to settle
    And I remember the text of "PLP hit count" as "unfiltered count"
    When I click on the "Filter" element
    And I click on the "first facet checkbox" element
    And I wait for the search results to update
    And I click on the "filter drawer close button" element if present
    Then the "PLP hit count" text should not equal the remembered "unfiltered count"
    And the "Filter" should not contain the text "(0)"


  Scenario: Pagination moves to the next page of results
    Given I am on the "special-offers" page
    And I wait for the page to settle
    And I remember the text of "PLP first product card title" as "first page product"
    When I click on the "PLP pagination next" element
    And I wait for the search results to update
    Then the "PLP first product card title" text should not equal the remembered "first page product"
    And the current URL should contain "page=2"


  Scenario: Adding to basket for delivery straight from the PLP
    Given I am on the "plywood" page
    And I wait for the page to settle
    When I click on the "PLP first product card delivery" element
    Then the "added to basket drawer" should be displayed within "15" seconds
