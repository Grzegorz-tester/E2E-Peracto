@regression
Feature: Accessories PLP

  # Ported from Insinkerator_EU's accessories-plp.feature. Unlike the EU
  # site, this storefront has no separate "/our-accessories" landing page
  # (confirmed 404 live) - the header nav's "Accessories" link goes
  # straight to the real, filterable /category/accessories PLP.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: User can filter, sort, load more, and reach the correct PDP
    When I navigate directly to the path "/category/accessories"
    Then the "hits heading" should be displayed
    And the "hit count" should be displayed
    And the "product card" should be displayed

    When I click on the "Filter & Sort" button
    And I apply the first facet filter and validate the result count updates
    And I close the filter drawer
    And I load more results and validate the count increases

    When I click on the "Filter & Sort" button
    And I sort by price low to high and validate ascending order
    And I click the first PLP result and remember its name as "accessories plp product"
    Then the "product name" text should equal the remembered "accessories plp product"
