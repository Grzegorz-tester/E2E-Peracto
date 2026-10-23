@regression
Feature: Product page quantity rules, timber lengths, multibuy and branch stock

  # Manual regression cases 180, 182, 184 and 191 (added 2026-10-23). Test
  # products are listed in basket-shipping-and-collection.feature's notes and
  # in pages.json (min-qty-product, multiples-product, timber-product,
  # multibuy-product, narrow-stock-product).


  Scenario: A minimum order quantity is shown, pre-filled and enforced
    Given I am on the "min-qty-product" page
    And I wait for the page to settle
    And I remember the price in "product price" as "unit price"
    Then the "PDP add to basket panel" should contain the text "minimum order quantity of 12"
    And the "Quantity input" should equal the value "12"
    And the "Quantity decrement" should not be enabled
    And the price in "PDP total price" should equal the remembered "unit price" times 12


  Scenario: A pack-size product only steps in its multiples
    Given I am on the "multiples-product" page
    And I wait for the page to settle
    Then the "PDP add to basket panel" should contain the text "only available in multiples of 520"
    And the "Quantity input" should equal the value "520"
    When I click precisely on the "Quantity increment" element
    Then the "Quantity input" should equal the value "1040"


  Scenario: Timber lengths add up to the total ordered length
    Given I am on the "timber-product" page
    And I wait for the page to settle
    Then the "PDP add to basket panel" should contain the text "You are ordering a total of: 0.00m"
    And the "DELIVERY" should not be enabled
    When I click precisely on the "first length increment" element
    Then the "PDP add to basket panel" should contain the text "You are ordering a total of: 4.20m"
    And the "DELIVERY" should be enabled
    When I click precisely on the "second length increment" element
    Then the "PDP add to basket panel" should contain the text "You are ordering a total of: 9.00m"


  Scenario: Multibuy deals show on eligible products only
    Given I am on the "multibuy-product" page
    And I wait for the page to settle
    Then the "PDP add to basket panel" should contain the text "Multibuy deals"
    And the "PDP add to basket panel" should contain the text "3+ units"
    And the "PDP add to basket panel" should contain the text "% off)"
    When I am on the "test-product" page
    And I wait for the page to settle
    Then the "PDP add to basket panel" should not contain the text "Multibuy deals"


  Scenario: Branches without stock can't be picked for Click & Collect
    Given I am on the "narrow-stock-product" page
    And I wait for the page to settle
    When I click on the "CLICK & COLLECT" button
    Then the "branch picker" should be displayed within "15" seconds
    And the "disabled branch select" should be displayed
    And the "Select this branch" should be enabled
