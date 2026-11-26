@regression
Feature: PDP details

  # CONFIRMED live 2026-09-23 on ray.lux Flat Glass with Kerb:
  # - The headline price (product-price__now-price) is a fixed "From £835.20"
  #   that NEVER changes with the chosen options - by design, not a bug. The
  #   price that tracks the selection is a separate "Total:" figure
  #   (product-price__flat-roof-window-price), £0.00 until an option is
  #   actually clicked (same reason Add to basket starts disabled even
  #   though a default lozenge shows selected - see basket-interactions.feature).
  # - CHANGED by 2026-11-11 (staging and 2-1-0): Kerb Type now renders
  #   ABOVE Opening Operation, and the opening options are Electric
  #   Opening, Fixed, Manual Opening (Electric Remote/Switch are gone). So
  #   visible lozenge order is PVC kerb, Electric Opening, Fixed, Manual
  #   Opening: "2nd" / "4th" below are Electric Opening / Manual Opening.
  #   "PDP selected opening operation" is scoped to that group's label,
  #   since the plain selected-value selector now hits the kerb first.
  #   Every PDP element is duplicated for mobile/desktop, hence :visible.
  # - 2026-11-11: the "Total:" figure was replaced by an order summary
  #   (product-order-summary__total, plus an operating-kit select for
  #   opening variants); "PDP total" now points there. Notes below about
  #   the old element are historical.
  # - "PDP total" is the amount <span> alone: the whole price element's
  #   text also includes every chosen option ("Size:500X500Opening
  #   Operation:Manual...Total:£1,252.80").
  # - Accordion/FAQ triggers don't take a real click (the sticky gallery
  #   panel overlaps them - same as the configurator), so JS-dispatch.

  Background:
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present

  Scenario: Choosing a different opening operation updates the total, and the basket charges that total
    Then the "product name" should contain the text "ray.lux"
    And the "product thumbnails" should be displayed
    When I click on the "2nd" "variant lozenge options" element
    And I wait for the page to settle
    Then the "PDP selected opening operation" should contain the text "Electric Opening"
    And the current URL should contain "opening_operation=electric"
    When I remember the text of "PDP total" as "electric opening total"
    And I click on the "4th" "variant lozenge options" element
    And I wait for the page to settle
    Then the "PDP selected opening operation" should contain the text "Manual"
    And the "PDP total" text should not equal the remembered "electric opening total"
    # Opening variants now REQUIRE an operating kit choice (2026-11-11):
    # Add to basket otherwise silently adds nothing and shows "Please choose
    # an operating kit, or select 'No, I already have one'". "No" keeps the
    # basket a single window line priced at the PDP total.
    When I click on the "1st" "operating kit none option" element via JavaScript
    And I wait for the page to settle
    And I remember the text of "PDP total" as "manual total"
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "basket item price" should contain the remembered "manual total"
    And the "basket item" should contain the text "Manual"

  Scenario: The product description and FAQ accordions open to show their content
    Then the "product accordion content" should not be displayed
    When I click on the "1st" "product accordion trigger" element via JavaScript
    Then the "product accordion content" should be displayed
    And the "FAQ content" should not be displayed
    When I click on the "1st" "FAQ trigger" element via JavaScript
    Then the "FAQ content" should be displayed
