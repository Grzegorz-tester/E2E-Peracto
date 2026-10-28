@smoke @regression
Feature: Product listing page

  # Qase BEN-101, BEN-103, BEN-104. Built 2026-10-24 from a live inspection
  # of staging's All kitchens listing (Algolia, 15 cards a page). Filters
  # live in a slide-out drawer opened by "Filter (n)"; the result count
  # updates as soon as a box is ticked. Counts are remembered rather than
  # hardcoded, since the catalogue changes.
  #
  # Confirmed 2026-10-24: filter and pagination clicks made before hydration
  # silently do nothing, hence the settle step before them. The first tick
  # can also land while the drawer is still sliding in and not register, so
  # it retries until checked (3/3 clean with RETRY=0 after that change).

  Scenario: The All kitchens PLP shows product cards that open the matching PDP
    Given I am on the "all-kitchens" page
    Then the "page heading" should contain the text "All kitchens"
    And the "hit count" should be displayed
    And I should see "15" "product cards" displayed
    And the "first product card image" should be displayed
    And the "first product card name" should be displayed
    When I remember the text of "first product card name" as "product name"
    And I click on the "first product card" link
    Then I should be redirected to the "pdp" page
    And the "product title" should contain the remembered "product name"

  Scenario: Applying a filter narrows the results and clearing it brings them all back
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "hit count" as "unfiltered count"
    And I click on the "Filter button" button
    Then the "filter drawer" should be displayed
    When I check the "first filter checkbox", retrying until it is checked
    Then the "hit count" text should not equal the remembered "unfiltered count"
    When I click on the "Close filter drawer" button
    Then the "applied filters" should be displayed
    When I click on the "Clear all filters" button
    Then the "hit count" text should equal the remembered "unfiltered count"
    And the "applied filters" should not be displayed

  # Confirmed live: page 2 shows a fresh 15 cards with none repeated from
  # page 1, and the page 2 button takes the active (filled) style.
  Scenario: Pagination loads the next page of products without repeating page 1
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "first product card name" as "page 1 first product"
    And I click on the "pagination page 2" button
    Then the "pagination page 2" should have class "bg-brand-primary"
    And I should see "15" "product cards" displayed
    And the "first product card name" text should not equal the remembered "page 1 first product"
    And the remembered "page 1 first product" should not appear in the "product card names" element
    When I click on the "pagination page 1" button
    Then the "first product card name" text should equal the remembered "page 1 first product"
