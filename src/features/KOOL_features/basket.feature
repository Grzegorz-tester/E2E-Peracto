@regression
Feature: Basket

  # From KOOL-2026-08-17.json, "Storefront > Basket" (cases 297-299,
  # 336-338). Runs as the "logged in" user on the "cable-pdp" page - the
  # same reliable pricing/add-to-basket combination pdp.feature already
  # established for this trade site (guest pricing is confirmed flaky).

  Background:
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    And I click on the "Accept cookies" button if present
    When I slowly click on the "Add to basket" button
    And I am on the "basket" page
    Then the "no items message" should not be displayed

  @smoke
  Scenario: Updating the item quantity recalculates the basket total
    When I remember the text of "product's total price" as "total at the default quantity"
    And I fill in the "basket quantity input" input field with "200"
    And I click on the "Update" button
    Then the "product's total price" text should not equal the remembered "total at the default quantity"

  @smoke
  Scenario: Removing the only item empties the basket and hides the checkout button
    When I click on the "remove item button" button
    Then the "no items message" should be displayed
    And the "CHECKOUT SECURELY" should not be displayed

  Scenario: An invalid promo code is rejected with an error message
    When I click on the "promo code toggle" element
    And I fill in the "promo code input" input field with "INVALIDCODE123"
    And I click on the "promo code apply button" button
    Then the "promo code error" should contain the text "This is not a valid promo code."
