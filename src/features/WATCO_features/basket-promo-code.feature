@regression
Feature: Basket - promotional codes

  # Coverage gap found 2026-10-24: the basket's "Got a promotional code?"
  # field was never exercised on any market.
  #
  # Backed by a dedicated staging fixture created 2026-10-24 in the legacy
  # Peracto admin (staging-uk.watco.pub/peracto, promotion id 647):
  # "Velstar Test Automation - VELSTARTEST1 (do not delete)", code
  # VELSTARTEST1, 1% basket line items percentage discount, all roles, no
  # per-customer limit, active until 2030-12-31 (the admin rejects an empty
  # end date). Do not delete it. UK only: each market has its own admin and
  # needs its own fixture before this can be copied.
  #
  # Guest-only and never checks out, so it is production-safe in shape, but
  # the code doesn't exist on prod: run it on staging.

  Background:
    Given I require staging for this scenario
    And I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    Then the "basket adjustments" should not be displayed

  Scenario: A valid promotional code discounts the basket, and removing it restores the original price
    When I fill in the "promo code input" input field with "VELSTARTEST1"
    And I click on the "promo code apply" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "basket message" should contain the text "VELSTARTEST1"
    And the "applied promo code" should contain the text "VELSTARTEST1"
    And the "basket adjustments" should be displayed
    And the "basket sub total inc adjustments" price should be "1"% less than the "basket sub total" price

    When I click on the "remove promo code" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "applied promo code" should not be displayed
    And the "basket adjustments" should not be displayed

  Scenario: An invalid promotional code is rejected and the basket is not discounted
    When I fill in the "promo code input" input field with "VELSTARNOTACODE"
    And I click on the "promo code apply" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "basket message" should contain the text "is not a valid promotion code"
    And the "applied promo code" should not be displayed
    And the "basket adjustments" should not be displayed
