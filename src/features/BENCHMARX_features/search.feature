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
