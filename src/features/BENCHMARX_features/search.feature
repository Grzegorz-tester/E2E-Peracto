@smoke @regression
Feature: Header search

  # Qase BEN-105. Built 2026-10-24 from a live inspection of staging. The
  # header search is Algolia autocomplete: typing shows product suggestions,
  # Enter goes to /search?q=<term>.

  Scenario: Searching by product name suggests and lists the product, and opens its PDP
    Given I am on the "home" page
    When I fill in the "header search input" input field with "Soho Gloss White"
    Then the "search suggestions" should be displayed
    And the "first search suggestion" should contain the text "Soho Gloss White"
    When I press Enter in the "header search input" input field
    Then I should be redirected to the "search" page
    And the current URL should contain "q=Soho"
    And the "page heading" should contain the text "Showing results for Soho Gloss White"
    And the "first product card name" should contain the text "Soho Gloss White"
    When I click on the "first product card" link
    Then I should be redirected to the "pdp" page
    And the "product title" should contain the text "Soho Gloss White"

  Scenario: Choosing a search suggestion opens that product's PDP
    Given I am on the "home" page
    When I fill in the "header search input" input field with "Cambridge"
    # The box shows default suggestions before Algolia answers for the typed
    # term, so wait for a matching one before remembering it.
    Then the "first search suggestion" should contain the text "Cambridge"
    When I remember the text of "first search suggestion" as "suggested product"
    And I click on the "first search suggestion" element
    Then I should be redirected to the "pdp" page
    And the "product title" should contain the remembered "suggested product"

  # Currently red on staging (2026-10-24): searching a product's SKU (e.g.
  # "05-soho-gloss-white", the sku on the Soho Gloss White product record)
  # finds nothing, in the suggestions or on /search. Kitchen SKUs may just
  # not be a searchable attribute in Algolia; confirm with the project team
  # whether SKU search is expected before treating this as a defect.
  Scenario: Searching by SKU finds the product
    Given I am on the "home" page
    When I fill in the "header search input" input field with "05-soho-gloss-white"
    And I press Enter in the "header search input" input field
    Then I should be redirected to the "search" page
    And the "page heading" should contain the text "Showing results for 05-soho-gloss-white"
    And the "first product card name" should contain the text "Soho Gloss White"

  # ---- BEN-379 (Next.js 15 upgrade) additions, 2026-11-11 ----
  # R1: on next-15 /search?q=<term> ignores the term and lists "All Products
  # (141)", with "An unexpected response was received from the server" in
  # the console. Staging (Next 14) shows "Showing results for oak (9)".
  # Counts are not hardcoded: only that the page is filtered to the term.

  # SRCH-02
  Scenario: Pressing Enter in the header search shows results for the term only
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "oak"
    # Wait for Algolia to answer for the typed term first (see the
    # suggestion scenario above): pressing Enter earlier submits "q=" or
    # nothing at all (confirmed on staging 2026-11-11).
    Then the "first search suggestion" should contain the text "Oak"
    When I press Enter in the "header search input" input field
    Then I should be redirected to the "search" page
    And the current URL should contain "q=oak"
    And the "page heading" should contain the text "Showing results for oak"
    And the "page heading" should not contain the text "All Products"

  # SRCH-03
  Scenario: Clicking the search icon shows results for the term only
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with "richmond"
    Then the "first search suggestion" should contain the text "Richmond"
    When I click on the "header search button" button
    Then I should be redirected to the "search" page
    And the "page heading" should contain the text "Showing results for richmond"
    And the "product card names" should contain the text "Richmond"

  # SRCH-04: the URL parameter is honoured on a direct visit and on reload.
  Scenario: Opening and reloading a search URL keeps the search term
    Given I navigate directly to the path "/search?q=richmond"
    Then the "page heading" should contain the text "Showing results for richmond"
    And the "product card names" should all contain the text "Richmond"
    When I reload the page
    Then the "page heading" should contain the text "Showing results for richmond"
    And the "product card names" should all contain the text "Richmond"

  # SRCH-05
  Scenario: A search with no matches shows the no-results message
    Given I navigate directly to the path "/search?q=zzzqqq"
    Then the "no results message" should be displayed
    And the "no results message" should contain the text "Sorry, we can't find any results for zzzqqq"
    And the "no results search input" should be displayed

  # SRCH-06
  Scenario: Searching from the menu drawer gives the same results as the header
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "menu button" button
    And I fill in the "menu search input" input field with "oak"
    Then the "first search suggestion" should contain the text "Oak"
    When I press Enter in the "menu search input" input field
    Then I should be redirected to the "search" page
    And the "page heading" should contain the text "Showing results for oak"

  # SRCH-07: filtering a result set stays within the search term.
  Scenario: Filtering search results keeps the search term
    Given I navigate directly to the path "/search?q=richmond"
    And I wait for the page to settle
    Then the "page heading" should contain the text "Showing results for richmond"
    When I remember the text of "hit count" as "search count"
    And I click on the "Filter button" button
    And I check the "first filter checkbox", retrying until it is checked
    And I click on the "Close filter drawer" button
    Then the "page heading" should contain the text "Showing results for richmond"
    And the "product card names" should all contain the text "Richmond"

  # SRCH-08: awkward input is handled safely: no error page, no script run,
  # the term is shown back as text.
  Scenario Outline: Searching for <case> is handled safely
    Given I start monitoring console errors, ignoring messages matching "Failed to load resource|GeolocationPositionError|exponea|Exponea|\bga\b"
    And I navigate directly to the path "/search?q=<query>"
    And I wait for the page to settle
    Then the "page heading" should be displayed
    And the "page heading" should not contain the text "Application error"
    And there should be no unexpected console errors

    Examples:
      | case                | query                                       |
      | an apostrophe       | o%27neill                                   |
      | an ampersand        | black%20%26%20white                         |
      | accented characters | caf%C3%A9                                   |
      | a script tag        | %3Cscript%3Ealert(1)%3C%2Fscript%3E         |
      | very long text      | aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa |
