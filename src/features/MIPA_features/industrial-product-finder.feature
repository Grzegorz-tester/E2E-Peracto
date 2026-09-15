@regression
Feature: Industrial Product Finder

  # Confirmed live: this is a 3-required/3-optional wizard (Product Type,
  # Substrate, Finishes required; Application, Technologies, Usage
  # optional), built from Radix comboboxes (button[role="combobox"] +
  # role="option" popups), not native <select> elements - the generic
  # "... listbox" step is the right fit, same shape already confirmed on
  # Indespension's towbar vehicle search.
  #
  # The three required fields cascade: Substrate stays disabled until a
  # Product Type is chosen, Finishes stays disabled until a Substrate is
  # chosen, and SEARCH itself stays disabled until all three are set.
  # Each field's own option list is pre-filtered server-side to only the
  # combinations that have at least one matching product, so there's no
  # genuine way to drive this wizard's UI into a zero-result search - a
  # "no matches" scenario isn't covered here for that reason (it would
  # require hand-crafting a facet URL rather than using the real UI).
  #
  # Guest-accessible (no login required) - confirmed live, same as the
  # rest of PLP browsing.
  #
  # SEARCH (and RESET SEARCH on the results page) needs the "retrying
  # until redirected" click variant, not a plain click - confirmed live,
  # the same hydration race documented elsewhere in this repo: the button
  # reports enabled and a plain forced click on it silently no-ops (native
  # disabled buttons don't fire their click handler, and the "disabled"
  # attribute clears a beat before the handler itself is wired up), only
  # succeeding on a later retry once the handler has actually attached.

  Scenario: Required filters are disabled until their prerequisite is selected, and SEARCH stays disabled until all three are set
    Given I am on the "industrial-product-finder" page
    Then the "page title" should contain the text "Industrial Product Finder"
    And the "Substrate" should not be enabled
    And the "Finishes" should not be enabled
    And the "SEARCH" should not be enabled
    When I select the "Top Coat" option from the "Product Type" listbox
    Then the "Substrate" should be enabled
    And the "Finishes" should not be enabled
    And the "SEARCH" should not be enabled
    When I select the "Painted" option from the "Substrate" listbox
    Then the "Finishes" should be enabled
    And the "SEARCH" should not be enabled
    When I select the "Matt" option from the "Finishes" listbox
    Then the "SEARCH" should be enabled


  Scenario: Searching with Product Type, Substrate and Finishes selected returns matching results
    Given I am on the "industrial-product-finder" page
    When I select the "Top Coat" option from the "Product Type" listbox
    And I select the "Painted" option from the "Substrate" listbox
    And I select the "Matt" option from the "Finishes" listbox
    Then the "SEARCH" should be enabled
    When I click on the "SEARCH" button, retrying until redirected to the "industrial-product-finder-results" page
    Then the "PLP hit count" should be displayed
    And the "PLP product cards" should be displayed
    And the "PLP first product card title" should be displayed
    And the "PLP current refinements" should contain the text "Top Coat"
    And the "PLP current refinements" should contain the text "Painted"
    And the "PLP current refinements" should contain the text "Matt"


  Scenario: CLEAR resets the selected filters without leaving the finder page
    Given I am on the "industrial-product-finder" page
    When I select the "Top Coat" option from the "Product Type" listbox
    Then the "Product Type" should contain the text "Top Coat"
    When I click on the "CLEAR" button
    Then the "Product Type" should contain the text "Please Select"
    And the "Substrate" should not be enabled


  # RESET SEARCH lives on the results page (inside "current refinements")
  # and confirmed live to navigate straight back to the finder with every
  # field reset to "Please Select".
  Scenario: RESET SEARCH on the results page returns to the finder with filters cleared
    Given I am on the "industrial-product-finder" page
    When I select the "Top Coat" option from the "Product Type" listbox
    And I select the "Painted" option from the "Substrate" listbox
    And I select the "Matt" option from the "Finishes" listbox
    Then the "SEARCH" should be enabled
    When I click on the "SEARCH" button, retrying until redirected to the "industrial-product-finder-results" page
    When I click on the "Reset Search" button, retrying until redirected to the "industrial-product-finder" page
    Then the "Product Type" should contain the text "Please Select"
