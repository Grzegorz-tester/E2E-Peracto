@MIPA_regression
Feature: Basket page

  # Full rewrite. Two structural bugs, both fixed:
  # (1) The Background navigated to a "place-order" page id that has never
  #     existed in pages.json - confirmed live, this is just the "basket"
  #     page (/basket); "place-order" was likely a HIB/earlier name for it.
  # (2) The selectors themselves lived in mappings/place-order.json, which
  #     was NEVER loaded - getElementLocator resolves a page's mapping file
  #     by matching its FILENAME to the current page id, and no page id
  #     "place-order" has ever existed either. Renamed to mappings/basket.json
  #     so it actually applies to the real "basket" page id.
  # Also removed: the previous version searched for and added products
  # directly from an inline "Search products" box on this page - confirmed
  # live, no such feature exists here. The only way to add an item is via a
  # PDP's "Add to basket" button (see pdp.feature); Quick Order CSV upload
  # (the only other way to add items from this page) is covered separately
  # in quick-order.feature.

  Scenario: Verify empty basket elements
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I clear the basket
    Then the "no items message" should be displayed
    And the "Checkout" should not be displayed


  Scenario: Changing the quantity of a basket item updates its total correctly
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    When I fill in the "Quantity selector" input field with "3"
    And I click on the "Update" button
    Then the "product's total price" should contain the text "36.69"
    And the "order total price" should contain the text "36.69"


  Scenario: Removing a product empties the basket
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    When I click on the "Remove items" element
    Then the "no items message" should be displayed
