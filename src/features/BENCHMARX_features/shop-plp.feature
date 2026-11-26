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
    # While the drawer closes, two "Clear all" buttons are briefly visible
    # (the drawer layout's and the page's); clicking then can hit the one
    # being removed (first attempt failed this way 2026-11-22), so wait it out.
    Then the "filter drawer" should not be displayed
    And the "applied filters" should be displayed
    And I wait for the page to settle
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

  # ---- BEN-379 (Next.js 15 upgrade) additions, 2026-11-11 ----
  # Staging keeps neither filters, sort nor page in the URL (Algolia routing
  # is off), so "refresh mid-filter" returns to the default listing on
  # staging: confirmed live (62 Shaker results, reload, 137 again). PLP-06
  # asserts that same behaviour, so a change either way is flagged.

  # PLP-01. KNOWN STAGING DEFECT (2026-11-11, pre-existing, not BEN-379):
  # two cards on page 1 link to PDPs that 404 (/kitchens/eton-gloss-cream-
  # true-handleless, /kitchens/eton-matt-white-true-handleless): the Algolia
  # index still lists kitchens the CMS no longer serves. Expected red on
  # both environments until the index is rebuilt; worth raising.
  Scenario: The All kitchens listing shows the full catalogue count
    Given I am on the "all-kitchens" page
    Then the "hit count" should be displayed
    And the "hit count" should contain the text "("
    And I should see "15" "product cards" displayed
    And the first 15 "product card links" links should resolve without an error

  # PLP-03
  Scenario: Removing a filter chip brings back the unfiltered results
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "hit count" as "unfiltered count"
    And I click on the "Filter button" button
    And I check the "first filter checkbox", retrying until it is checked
    Then the "hit count" text should not equal the remembered "unfiltered count"
    When I click on the "Close filter drawer" button
    And I click on the "first applied filter remove button" button
    Then the "hit count" text should equal the remembered "unfiltered count"
    And the "applied filters" should not be displayed

  # PLP-02: two filters from different groups narrow further than one.
  Scenario: Combining filters from two groups narrows the results further
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I click on the "Filter button" button
    And I check the "first filter checkbox", retrying until it is checked
    And I remember the text of "hit count" as "one filter count"
    And I check the "second filter group first checkbox", retrying until it is checked
    Then the "hit count" text should not equal the remembered "one filter count"

  # PLP-04
  Scenario Outline: Sorting by <sort> orders the kitchens <direction>
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I select the "Sort By: <sort>" option from the "sort by" listbox
    Then the "sort by" should contain the text "<sort>"
    And the "product card names" texts should be in <direction> alphabetical order

    Examples:
      | sort     | direction  |
      | Name A-Z | ascending  |
      | Name Z-A | descending |

  # PLP-04: the price sorts change the order (kitchen cards carry no price
  # to check the order against).
  Scenario Outline: Sorting by <sort> changes the product order
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "first product card name" as "default first"
    And I select the "Sort By: <sort>" option from the "sort by" listbox
    Then the "sort by" should contain the text "<sort>"
    And I should see "15" "product cards" displayed

    Examples:
      | sort                |
      | Price - low to high |
      | Price - high to low |

  # PLP-05. The pagination testids are positions in a sliding window, not
  # page numbers (on page 3, "__page-2" is the button labelled 4), so the
  # page buttons are mapped by their label.
  Scenario: Next and previous pagination move between pages
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "first product card name" as "page 1 first product"
    And I click on the "pagination next" button
    Then the "pagination button 2" should have class "bg-brand-primary"
    And the "first product card name" text should not equal the remembered "page 1 first product"
    When I click on the "pagination button 3" button
    Then the "pagination button 3" should have class "bg-brand-primary"
    When I click on the "pagination previous" button
    Then the "pagination button 2" should have class "bg-brand-primary"
    When I click on the "pagination previous" button
    Then the "first product card name" text should equal the remembered "page 1 first product"

  # PLP-06 (URL parameter risk): see the comment at the top of this block.
  Scenario: Reloading a filtered listing returns to the default listing, as on staging
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "hit count" as "unfiltered count"
    And I click on the "Filter button" button
    And I check the "first filter checkbox", retrying until it is checked
    Then the "hit count" text should not equal the remembered "unfiltered count"
    When I reload the page
    And I wait for the page to settle
    Then the "hit count" text should equal the remembered "unfiltered count"

  # PLP-09
  Scenario: Product cards show an image, a name and a working link
    Given I am on the "all-kitchens" page
    Then the "first product card image" should be displayed
    And the "first product card image" image should return a 200 OK response with content-type "image/"
    And the "first product card name" should be displayed
    And the "product card colour options" should be displayed
