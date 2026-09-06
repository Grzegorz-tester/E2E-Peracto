@smoke
@regression
Feature: Basket

  # Uses the PDP's always-visible "quick-select" widget (lozenge options for
  # Opening Operation/Kerb Type/Size) rather than the "Build & Buy" step
  # wizard - see product-configurator.feature for that journey.
  #
  # CONFIRMED live 2026-09-06: "Add to basket" starts DISABLED until an
  # actual option is picked, even though one lozenge in each group already
  # shows as selected on page load (a default value exists, but the button
  # only enables once the user has genuinely interacted with a lozenge) -
  # picking any one lozenge is enough to enable it and lands the configured
  # variant in the basket.

  Scenario: Adding a window straight from the PDP shows it in the basket
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket item" should be displayed
    And the "basket total" should be displayed
