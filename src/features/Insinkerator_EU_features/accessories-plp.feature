@regression
Feature: Accessories PLP

  # Ported from P3Playwright's insinkerator_eu/tests/plp/
  # accessories-plp.test.ts. /our-accessories is an informational landing
  # page; its own "Shop" CTA (-> /category/accessories) is what reaches the
  # real, filterable PLP - distinct from the header's own "Shop" nav link,
  # which goes to /category/shop instead. "Our Accessories" has children in
  # the nav drawer, so choosing it expands to a tier-2 "View All" view
  # rather than navigating directly (unlike a leaf category such as "Shop").
  #
  # CONFIRMED SITE BUG (live, 2026-08-15): Load More's click stops updating
  # the result count while the Filter & Sort drawer is still open over the
  # page - even though the button underneath remains visible/clickable with
  # no Playwright-visible intercepted-click error. Closing the drawer via
  # its own Close button (not just assuming Escape or a later action
  # dismissed it) before Load More avoids that state; the drawer is then
  # reopened for the Sort step, which closes it again the same way
  # afterwards.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present

  @smoke
  Scenario: User can filter, sort, load more, and reach the correct PDP
    When I click on the "Menu" button
    And I choose the "Our Accessories" category from the menu
    And I click on the "View All accessories" link
    Then the current URL should contain "our-accessories"

    When I click on the "Shop (accessories landing)" button
    Then the current URL should contain "category/accessories"
    And the "hits heading" should be displayed
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
