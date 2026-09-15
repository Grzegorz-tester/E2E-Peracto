@regression
Feature: Product page

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. Searching "epoxy" and following the first result reaches a
  # PDP whose default variant (colour/volume) is already preselected, so
  # Add to basket works without any variant selection step first - the same
  # search term the existing per-market VAT suite already depends on (see
  # guest-checkout-vat-field.feature), so it's already confirmed to return
  # a result on every Watco market's own catalogue.

  Scenario: A product page displays its title, breadcrumb and price, and Add to basket updates the basket count
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    Then I should be redirected to the "pdp" page
    And the "PDP title" should be displayed
    And the "PDP breadcrumb" should be displayed
    And the "PDP price" should be displayed

    When I click on the "Add to basket" button
    Then the "basket header link" should contain the text "1"

  # CONFIRMED LIVE (staging-uk, 2026-09-09): colour options render as
  # custom <div> swatches (".product-configurable__swatch"), not native
  # <select>/radio inputs - clicking one moves a "current" class from the
  # previously selected swatch to the clicked one. This particular product
  # line's colour choice doesn't change price (RAL colour only, no cost
  # delta), so the assertion is scoped to the swatch's own selected state
  # rather than a price change - see product-configurator.ts's "finish
  # options" steps for a different Watco/Insinkerator product line where a
  # variant DOES carry its own price.
  Scenario: Selecting a colour option updates which swatch is marked selected
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    Then I should be redirected to the "pdp" page
    And the "colour option swatches" should be displayed

    When I click on the "3rd" "colour option swatches" element
    Then the "3rd" "colour option swatches" should have class "current"

  # CONFIRMED LIVE (staging-uk, 2026-09-09): every PDP checked embeds a
  # Feefo review widget under a "What our customers say" heading - no PDP
  # in this suite had ever asserted a reviews section exists at all.
  Scenario: The reviews section is displayed on a product page
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    Then the "reviews section" should be displayed
