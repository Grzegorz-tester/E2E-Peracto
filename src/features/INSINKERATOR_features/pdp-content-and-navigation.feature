@regression
Feature: PDP content and navigation

  # Ported from Insinkerator_EU's pdp-content-and-navigation.feature, on
  # /products/standard-460 - a configurable-bundle PDP also covered for its
  # configurator/basket behaviour by product-configurator.feature. This
  # covers the rest of that same PDP's content and navigation surface: the
  # Overview/Features/Specifications/Downloads accordion and the separate
  # FAQs accordion (both single-open behaviour), the Comparison Table's
  # "View Product" links, the Product Features carousel, and the image
  # zoom lightbox.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I navigate directly to the path "/products/standard-460"

  Scenario: Overview/Features/Specifications/Downloads accordion allows only one section open at a time
    Then the "accordion trigger" accordion should allow only one section open at a time

  Scenario: FAQ accordion allows only one question open at a time
    Then the "faq accordion trigger" accordion should allow only one section open at a time

  Scenario: Comparison table "View Product" link navigates to the correct PDP
    When I click "View Product" for a different product in the comparison table, remembering its name as "comparison target"
    Then the "product name" text should equal the remembered "comparison target"

  # Whether "next" should be enabled depends on whether the carousel's own
  # content actually overflows at the CURRENT viewport - both prev/next
  # being disabled at a wide viewport is the correct state there, not a bug.
  Scenario: Product Features carousel navigation behaves correctly for the current viewport
    Then the product features carousel navigation should match the current viewport's overflow state

  Scenario: Expand image opens and closes the zoom lightbox
    When I click on the "Expand image" icon
    Then the "image zoom modal" should be displayed

    When I click on the "Minimize image" icon
    Then the "image zoom modal" should not be displayed
