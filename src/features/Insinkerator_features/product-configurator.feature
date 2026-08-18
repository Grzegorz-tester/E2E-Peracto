@regression
Feature: PDP product configurator

  # Ported from Insinkerator_EU's product-configurator.feature, on
  # /products/standard-460 - a configurable-bundle PDP, a different
  # template from the simpler sink-flange-pdp used by
  # basket-interactions.feature. Selects the first available priced
  # (non-"Included") configurator option generically, so this doesn't
  # depend on hardcoded catalog variant names/IDs.

  @smoke
  Scenario: Selecting a priced option updates the Total, and the basket reflects the configured bundle
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
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

  # Same bundle-configurator template as standard-460 above (sink flange /
  # air switch / installation option groups, each with an "(Included)" free
  # default), applied to a waste disposer PDP - confirms the generic
  # configurator steps aren't coupled to one specific product.
  @smoke
  Scenario: Selecting a priced sink flange updates the Total on a waste disposer PDP, and the basket reflects it
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I navigate directly to the path "/products/evolution-plus-750-ec"

    When I remember the text of "product name" as "disposer product name"
    And I remember the text of "product sku" with the prefix "SKU" stripped, as "disposer product sku"
    And I select the first priced configurator option and validate the PDP total updates
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button

    When I am on the "basket" page
    Then the "basket main product name" text should equal the remembered "disposer product name"
    And the "basket main product sku" should contain the remembered "disposer product sku"
    And the basket should show the configured extra matching the PDP selection
    And the basket grand total should be internally consistent
