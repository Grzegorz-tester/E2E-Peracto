@regression
Feature: Shop PLP

  # Covers Benchmarx BEN-402 (Next 15: on mobile, closing the Filter & Sort
  # drawer cleared the filters just applied), re-checked on this site
  # 2026-11-26. The rest of the PLP (filter, sort, load more, PDP) is covered
  # by accessories-plp.feature on the same Algolia template, so this only
  # checks what survives closing the drawer at phone width (390px).
  # Confirmed live 2026-11-26: Shop (52) -> tick Sink Flange -> Shop (8),
  # and after Close the heading, the filter chip and Clear all all stay.

  Background:
    Given I am on the "shop-plp" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present

  Scenario: On mobile, a filter stays applied after closing the Filter & Sort drawer
    When I resize the browser to a "mobile" viewport
    And I remember the text of "hits heading" as "unfiltered heading"
    And I click on the "Filter & Sort" button
    And I click on the "Sink Flange filter" element
    Then the "hits heading" text should not equal the remembered "unfiltered heading"
    When I remember the text of "hits heading" as "filtered heading"
    And I click on the "filter drawer close button" button
    Then the "filter drawer" should not be displayed
    And the "hits heading" text should equal the remembered "filtered heading"
    And the "applied filter chip" should contain the text "Sink Flange"
    And the "Clear all filters" should be displayed
