@regression
Feature: PDP product configurator

  # Ported from P3Playwright's insinkerator_eu/tests/pdp/
  # product-configurator.test.ts, on /products/standard-460 - a
  # configurable-bundle PDP, a different template from the simpler
  # sink-flange-pdp used by basket-interactions.feature. Selects the first
  # available priced (non-"Included") configurator option generically, so
  # this doesn't depend on hardcoded catalog variant names/IDs.
  #
  # CONFIRMED SITE BUG: the PDP's advertised price delta for a configured
  # extra can differ from what the basket displays for the SAME selection by
  # a small (~1 cent) rounding amount - asserted with a documented tolerance.

  @smoke
  Scenario: Selecting a priced option updates the Total, and the basket reflects the configured bundle
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    And I navigate directly to the path "/products/standard-460"

    When I remember the text of "product name" as "configurator product name"
    And I remember the text of "product sku" with the prefix "SKU" stripped, as "configurator product sku"
    And I select the first priced configurator option and validate the PDP total updates
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button

    When I am on the "basket" page
    Then the "basket main product name" text should equal the remembered "configurator product name"
    And the "basket main product sku" should contain the remembered "configurator product sku"
    And the basket should show the configured extra matching the PDP selection
    And the basket grand total should be internally consistent
