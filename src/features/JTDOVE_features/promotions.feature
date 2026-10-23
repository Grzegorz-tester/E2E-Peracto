@regression
Feature: Promotions

  # Manual regression cases 91-102 (added 2026-10-23). Every promotion used
  # here is a permanent staging fixture created for these tests through the
  # admin API (identifiers velstar-test-*, promotions 15-26). All are code-
  # only, so they never apply to anyone else's basket. Do not delete them.
  #   VELSTAR10           10% off, custom success message
  #   VELSTARSAND10       10% off Yellow Building Sand (351725) only
  #   VELSTARFIXEDITEM    £1 off each Everbuild C3 sealant (360384)
  #   VELSTARFIXEDBASKET  £5 off a basket of £20 or more
  #   VELSTAREXPIRED      ran Jan 2026 only;  VELSTARFUTURE starts 2036
  #   VELSTARCOMBOA / B   B is set as incompatible with A
  #   VELSTARPRIOFIXED    £10 off, priority 1;  VELSTARPRIOPCT 10% off, priority 2
  #   VELSTARLIMITEMAIL   one use per email; already used by the shared test
  #                       account (setup order, 2026-10-23)
  # Fixed amounts are stored in pence in Peracto (100 = £1).
  #
  # Not automated: the promotion-level "Limit Total Uses" (manual case 96).
  # VELSTARLIMITTOTAL (max 1 use) was used on a real order on 2026-10-23,
  # but its use counter stayed at 0 and any customer can still apply it.
  # Raised with QA as a suspected defect.

  Background:
    Given I am on the "test-product" page
    And I wait for the page to settle


  Scenario: A promotion code applies its discount and custom success message
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTAR10"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar test promotion applied"
    And the "applied promotions" should contain the text "Velstar Test - 10% off (code VELSTAR10)"
    And the "basket total" price should be "10"% less than the "basket sub total" price


  Scenario: A product-specific promotion only reduces the eligible product
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "wide-stock-product" page
    And I wait for the page to settle
    And I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARSAND10"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar test sand promotion applied"
    # The discount is 10% of the sand line alone, not of the whole basket.
    And the "basket discount" price should be "90"% less than the "sand line total" price


  Scenario: A fixed per-product discount is taken off each unit
    When I am on the "multibuy-product" page
    And I wait for the page to settle
    And I click precisely on the "Quantity increment" element
    And I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARFIXEDITEM"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar test fixed item promotion applied"
    And the "basket discount" should contain the text "£2.00"


  Scenario: A fixed basket discount applies once the basket meets its minimum
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARFIXEDBASKET"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar test basket promotion applied"
    And the "basket discount" should contain the text "£5.00"


  Scenario: A basket below the promotion's minimum is refused
    When I am on the "multibuy-product" page
    And I wait for the page to settle
    And I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARFIXEDBASKET"
    And I click on the "Apply promo code" button
    Then the "basket summary" should contain the text "This is not a valid promo code"
    And the "basket discount" should not be displayed


  Scenario Outline: A promotion outside its date range is refused (<code>)
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "<code>"
    And I click on the "Apply promo code" button
    Then the "basket summary" should contain the text "This is not a valid promo code"
    And the "basket discount" should not be displayed
    Examples:
      | code           |
      | VELSTAREXPIRED |
      | VELSTARFUTURE  |


  Scenario: An incompatible promotion can't be added on top of another
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARCOMBOA"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar combo A applied"
    When I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARCOMBOB"
    And I click on the "Apply promo code" button
    Then the "basket summary" should contain the text "This is not a valid promo code"
    And the "applied promotions" should contain the text "combo A"
    And the "applied promotions" should not contain the text "combo B"


  # Entered percentage first, fixed second, yet the fixed (priority 1)
  # applies first: £56.98 - £10 = £46.98, then 10% = £4.70, so £14.70 off.
  # Applying in entry order would give £15.70. Tied to the plywood's £56.98
  # staging price.
  Scenario: Promotion priority decides the order discounts are applied in
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARPRIOPCT"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar priority percent applied"
    When I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARPRIOFIXED"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "Velstar priority fixed applied"
    And the "basket sub total" should contain the text "£56.98"
    And the "basket discount" should contain the text "£14.70"


  Scenario: A per-email limited promotion still works for a new customer
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARLIMITEMAIL"
    And I click on the "Apply promo code" button
    Then the "applied promotions" should contain the text "per-email limit"


  Scenario: A per-email limited promotion is refused once that customer has used it
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARLIMITEMAIL"
    And I click on the "Apply promo code" button
    Then the "basket summary" should contain the text "This is not a valid promo code"
