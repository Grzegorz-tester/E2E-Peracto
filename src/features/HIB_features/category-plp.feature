@regression
Feature: Category pages (PLP)

  # Built 2026-09-29 from a live crawl of every category page linked from the
  # menu draw and footer on feature-hib-170. The existing products.feature
  # covers the Products hub, filtering and sorting; this covers every
  # category actually listing products and leading on to a PDP.
  #
  # There is no pagination or "load more" on either the release or production:
  # large categories (Mirrors, Cabinets, Wall Hung Units...) show exactly 39
  # cards even though their facet counts add up to more. Same on production,
  # so it isn't asserted here as a bug.

  Scenario Outline: The "<path>" category lists products with filters and sorting
    Given I navigate directly to the path "<path>"
    And I dismiss the newsletter popup if present
    Then the "application error" should not appear within "3" seconds
    And the "product card" should be displayed
    And the "product card name" should be displayed
    And the "product card image" should be displayed
    And the "Filter" should be displayed
    And the "Sort By" should be displayed
    And the "breadcrumb" should be displayed

    Examples:
      | path                                    |
      | /category/bathroom-mirrors              |
      | /category/bathroom-cabinets             |
      | /category/wall-hung-bathroom-units      |
      | /category/bathroom-cloakroom-units      |
      | /category/bathroom-floor-standing-units |
      | /category/bathroom-fitted-furniture     |
      | /category/bathroom-washbasins           |
      | /category/bathroom-brassware            |
      | /category/bathroom-countertops          |
      | /category/bathroom-handles              |
      | /category/bathroom-back-to-wall-units   |
      | /category/bathroom-tall-storage-units   |
      | /category/bathroom-toilet               |
      | /category/bathroom-basins               |
      | /category/bathroom-accessories          |
      | /category/bathroom-ventilation          |
      | /category/bathroom-lighting             |


  Scenario Outline: Clicking a product on the "<path>" category opens its PDP
    Given I navigate directly to the path "<path>"
    And I dismiss the newsletter popup if present
    When I click on the "first product card" element
    Then I should eventually be redirected to the "product" page
    And the "application error" should not appear within "5" seconds
    And the "product price" should contain the text "£"

    Examples:
      | path                               |
      | /category/bathroom-mirrors         |
      | /category/wall-hung-bathroom-units |
      | /category/bathroom-brassware       |
      | /category/bathroom-lighting        |


  Scenario: The Bathroom Furniture hub lists its sub-categories, which lead on to a category page
    Given I am on the "bathroom-furniture" page
    And I dismiss the newsletter popup if present
    Then the "subcategory links" should be displayed
    When I click on the "first subcategory link" element
    Then I should eventually be redirected to the "category" page
    And the "product card" should be displayed
