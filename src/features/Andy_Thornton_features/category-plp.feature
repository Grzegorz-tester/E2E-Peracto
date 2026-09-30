@regression
Feature: Category landing pages, venue pages and PLPs

  # Built 2026-09-30 from a live inspection of staging. PLP.feature and
  # products.feature cover Dining Chairs' elements, filtering and a
  # "first product changed" sort check; this covers every Contract Furniture
  # sub-category, the venue pages, real price ordering and pagination.
  #
  # Staging data note: the cheapest "dining chair" is £0.99 - looks like a
  # placeholder product, not asserted on.

  Background:
    Given I am on the "home" page
    And I click on the "Allow all cookies" button if present


  Scenario: The Contract Furniture landing page lists its sub-categories, which lead to a PLP
    When I am on the "contract-furniture" page
    Then the "subcategory links" should be displayed
    When I click on the "first subcategory link" element
    Then I should eventually be redirected to the "category" page
    And the "product card" should be displayed
    And the "hit count" should be displayed


  Scenario Outline: The "<path>" PLP lists products with a count, filters and sorting
    When I navigate directly to the path "<path>"
    Then a heading with the text "<heading>" should be displayed
    And the "product card" should be displayed
    And the "hit count" should be displayed
    And the "Filter" should be displayed
    And the "Sort By" should be displayed

    Examples:
      | path                                        | heading         |
      | /category/contract-furniture/dining-chairs  | Dining Chairs   |
      | /category/contract-furniture/lounge-seating | Lounge Seating  |
      | /category/contract-furniture/benches        | Benches         |
      | /category/contract-furniture/table-bases    | Table Bases     |
      | /category/contract-furniture/complete-tables | Complete Tables |
      | /category/contract-furniture/table-tops     | Table Tops      |


  # Only Pub Furniture has a product grid (confirmed live 2026-09-30, even
  # after scrolling); Hotel, Café, Bar and Restaurant are content-only pages
  # (text and images), covered by health-check.feature instead.
  Scenario Outline: The "<path>" venue page lists products, and a product opens its PDP
    When I navigate directly to the path "<path>"
    Then the "product card" should be displayed
    When I click on the "first product card" element
    Then I should eventually be redirected to the "product" page
    And the "product price" should contain the text "£"

    Examples:
      | path           |
      | /pub-furniture |


  Scenario: Sorting by price low to high orders the products by ascending price
    When I am on the "dining-chairs" page
    And I select the "Sort By: Price - low to high" option from the "Sort By" listbox
    Then the current URL should contain "sortBy=price_asc"
    And the "product card prices" prices should be sorted in "ascending" order


  Scenario: Sorting by price high to low orders the products by descending price
    When I am on the "dining-chairs" page
    And I select the "Sort By: Price - high to low" option from the "Sort By" listbox
    Then the current URL should contain "sortBy=price_desc"
    And the "product card prices" prices should be sorted in "descending" order


  Scenario: The next page of a PLP shows different products
    When I am on the "dining-chairs" page
    And I remember the text of "first product name" as "first product on page 1"
    And I click on the "next page" button
    Then the current URL should contain "page=2"
    And the "first product name" text should not equal the remembered "first product on page 1"
