@regression
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
    And I wait for the page to settle
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
    And I wait for the page to settle
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
    And I wait for the page to settle
    When I click on the "Remove items" element
    Then the "no items message" should be displayed


  # 2026-09-25: every promotion MIPA itself runs on staging (the same
  # backend feature-next-15 uses) is conditional on specific SKUs/quantities
  # - e.g. WINNER2000 is rejected with the same "not a valid promo code"
  # message unless its trigger product is in the basket - so a dedicated
  # test promotion was created in the MIPA staging admin for the success
  # path: "Velstar Test 1% Off" (promotion id 17, identifier
  # velstar-test-1-percent), code VELSTARTEST1, 1% off everything, no
  # conditions, 999999 uses (per email too) so repeated runs never exhaust
  # it. The scenario only applies it in the basket - no order is placed.
  # Confirmed live: 1% of £12.23 shows as a £0.13 discount (the site rounds
  # the discount UP), total £12.10.
  # If this starts failing with "not a valid promo code", check promotion 17
  # still exists and is Active in the staging admin before suspecting the
  # storefront - it's shared staging data anyone could edit.
  Scenario: An invalid promo code is rejected
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    And I wait for the page to settle
    When I click on the "Add a promo code" element
    And I fill in the "Promo code input" input field with "VELSTARTESTINVALID"
    And I click on the "Apply promo code" button
    Then the "invalid promo code message" should be displayed
    When I click on the "Remove items" element
    Then the "no items message" should be displayed


  Scenario: A valid promo code applies its discount to the basket
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    And I wait for the page to settle
    When I click on the "Add a promo code" element
    And I fill in the "Promo code input" input field with "VELSTARTEST1"
    And I click on the "Apply promo code" button
    Then the "applied promo code tag" should contain the text "VELSTARTEST1"
    And the "total discount" should contain the text "0.13"
    And the "basket summary total" should contain the text "12.10"
    When I click on the "Remove items" element
    Then the "no items message" should be displayed
