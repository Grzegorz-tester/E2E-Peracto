@regression
Feature: PDP product configurator

  # Ported from Insinkerator_EU's product-configurator.feature. Selects the
  # first available priced (non-"Included") configurator option generically,
  # so this doesn't depend on hardcoded catalog variant names/IDs.
  #
  # Originally covered two PDPs on this template (standard-460 and
  # evolution-plus-750-ec below), to prove the generic steps aren't coupled
  # to one specific product. Dropped standard-460 (2026-09-22): CONFIRMED
  # live that production renders an "Enquire Now" CTA instead of "Add to
  # basket" for that PDP (0 "Add to basket" buttons on production vs 4 on
  # staging for the same URL) - a genuine content/business divergence, not a
  # selector gap, and not something this suite should keep failing on until
  # someone confirms whether that's intentional. evolution-plus-750-ec
  # supports direct purchase on both environments, so it's now the only PDP
  # this feature covers - swap/add a second PDP here if standard-460 (or
  # another bundle-configurator product) becomes purchasable again.

  # Sink flange / air switch / installation option groups, each with an
  # "(Included)" free default.
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

  # Installation is offered in the basket as a standalone "Additional
  # Services" card; ticking it adds the service as its own basket line.
  # History: until 2026-10-13 the disposer line ALSO had its own
  # Installation tick box, which never worked (no basket request, box
  # stayed unticked). That box was removed from staging on 2026-10-13, and
  # the separate "Installation" card went with it - only "Food Waste
  # Disposer Installation" remains. Matched by "Installation" in the name
  # so a rename doesn't break it.
  Scenario: Adding Installation to a waste disposer in the basket adds the service price to the basket total
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I navigate directly to the path "/products/evolution-plus-750-ec"
    And I select the first priced configurator option and validate the PDP total updates
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button

    When I am on the "basket" page
    And I click on the "Accept cookies" button if present
    And I remember the price in "basket total" as "total before installation"
    And I remember the price in "installation service price" as "installation price"
    And I click on the "installation service checkbox" button
    Then the price in "basket total" should equal the remembered "total before installation" plus the remembered "installation price"
    And the price in "basket installation line total" should equal the remembered "installation price"
