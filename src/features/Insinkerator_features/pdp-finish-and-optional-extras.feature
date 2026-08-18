@regression
Feature: PDP finish selection and optional extras

  # Ported by hand from the /products/4n1-touch-l-shape-instant-how-water-tap45356-ise-45094
  # tap PDP - a different template again from both the simpler
  # sink-flange-pdp (basket-interactions.feature) and the bundle
  # configurator (product-configurator.feature): finish/colour is a group of
  # ABSOLUTE-priced swatches rather than "+ price" deltas, and the chiller/
  # installation add-ons are single checkbox toggles rather than a
  # radio-select group. Selects generically (first differently-priced
  # finish, first priced checkbox) so this doesn't depend on hardcoded
  # catalog variant names/IDs.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I navigate directly to the path "/products/4n1-touch-l-shape-instant-how-water-tap45356-ise-45094"

  @smoke
  Scenario: Selecting a different finish updates the Total, and the basket reflects the chosen finish and price
    # Selecting a different finish navigates to that finish's own variant
    # URL/SKU, so the name/SKU to compare against the basket must be
    # remembered AFTER selecting it, not before.
    When I select a different finish option and validate the PDP price updates
    And I remember the text of "product name" as "tap product name"
    And I remember the text of "product sku" with the prefix "SKU" stripped, as "tap product sku"
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button

    When I am on the "basket" page
    Then the "basket main product name" text should equal the remembered "tap product name"
    And the "basket main product sku" should contain the remembered "tap product sku"
    And the basket should show the selected finish

  Scenario: Adding an optional extra updates the Total, and the basket reflects it as a priced line
    When I check the first optional extra and validate the PDP total updates
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button

    When I am on the "basket" page
    Then the basket should show the configured extra matching the PDP selection
    And the basket grand total should be internally consistent

  Scenario: Unchecking an optional extra reverts the Total
    When I check the first optional extra and validate the PDP total updates
    Then I uncheck that optional extra and validate the PDP total reverts
