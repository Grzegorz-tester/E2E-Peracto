@regression
Feature: VAT toggle

  # Covers the header's global "Incl./Excl. VAT" switch (present on every
  # page) and that flipping it is reflected in the prices shown on the PDP,
  # a category PLP, and the header's live search-results dropdown. The
  # switch's own visible label always reads "Incl. VAT" regardless of
  # state - only the underlying checkbox's checked state (read via "the
  # product price tax message" label on the PDP) is the reliable signal.

  @smoke
  Scenario: PDP price and VAT label reflect the header VAT toggle
    Given I navigate directly to the path "/products/roller-for-cnh-nh-92087109"
    And I click on the "Accept cookies" button if present
    When I uncheck the "VAT toggle"
    Then the "product price tax message" should equal text "Excl. VAT"
    And I remember the text of "product price" as "excl vat price"

    When I ensure the "VAT toggle" checkbox is checked
    Then the "product price tax message" should equal text "Incl. VAT"
    And the "product price" text should not equal the remembered "excl vat price"

  Scenario: PLP price reflects the header VAT toggle
    Given I navigate directly to the path "/category/general-parts-pto-driveline-components"
    And I click on the "Accept cookies" button if present
    And the "product card" should be displayed
    When I uncheck the "VAT toggle"
    And I remember the text of "product card price" as "excl vat price"
    And I ensure the "VAT toggle" checkbox is checked
    Then the "product card price" text should not equal the remembered "excl vat price"

  Scenario: Search results dropdown price reflects the header VAT toggle
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I uncheck the "VAT toggle"
    And I fill in the "Search bar" input field with "bearing"
    And I wait for the search results to update
    And I remember the text of "search hit product price" as "excl vat price"

    When I am on the "home" page
    And I ensure the "VAT toggle" checkbox is checked
    And I fill in the "Search bar" input field with "bearing"
    And I wait for the search results to update
    Then the "search hit product price" text should not equal the remembered "excl vat price"
