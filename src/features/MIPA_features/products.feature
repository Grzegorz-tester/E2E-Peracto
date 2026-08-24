@MIPA_regression
Feature: Product Listing Page (PLP)

  # Full rewrite - the previous version pointed at "bathroom-cabinets"/
  # "bathroom-mirrors" pages (HIB categories that don't exist here) and an
  # "Apex checkbox" filter with no real equivalent, and asserted nothing.
  # Rebuilt against a real MIPA category listing, confirmed live.
  #
  # Note: there is no "add to basket directly from the PLP" feature on
  # MIPA (confirmed live, logged in) - each card only has a "View Product"
  # link through to the PDP, no basket action. Covered here as the real
  # behaviour instead of the smoke-test assumption that one exists.

  Scenario: PLP loads with products displayed correctly
    Given I am on the "all-refinishing" page
    Then the "category page title" should contain the text "All Refinishing"
    And the "PLP hit count" should be displayed
    And the "PLP product cards" should be displayed
    And the "PLP first product card title" should be displayed


  # Uses the retrying click variant below - confirmed live, this exact
  # click occasionally no-ops silently (the site's own Next.js router
  # throws "TypeError: Failed to fetch" internally and just stays put,
  # with no error Playwright can see) - a plain click + redirect check
  # was intermittently failing for this reason, not a selector problem.
  Scenario: Clicking a product on the PLP navigates to its PDP
    Given I am navigating the page as a "logged in" user
    And I am on the "all-refinishing" page
    When I click on the "PLP first product card view product" element, retrying until redirected to the "pdp" page
    Then the "product title" should be displayed
    And the "product SKU" should be displayed


  Scenario: Guest user cannot see prices on the PLP
    Given I am navigating the page as a "guest" user
    And I am on the "all-refinishing" page
    Then the "PLP first product card guest login link" should be displayed
    When I click on the "PLP first product card view product" element, retrying until redirected to the "pdp" page
    Then the "product title" should be displayed


  Scenario: Applying a filter updates the results and clearing it restores them
    Given I am on the "ready-mixed-colours" page
    And the "PLP hit count" should contain the text "(41)"
    When I click on the "Black filter checkbox" element
    Then the "PLP hit count" should not contain the text "(41)"
    And the "PLP current refinements" should be displayed
    When I click on the "Black filter checkbox" element
    Then the "PLP hit count" should contain the text "(41)"


  Scenario: Pagination loads additional results
    Given I am on the "all-refinishing" page
    And the "PLP first product card title" should be displayed
    When I click on the "PLP pagination next" element
    Then the "PLP product cards" should be displayed
