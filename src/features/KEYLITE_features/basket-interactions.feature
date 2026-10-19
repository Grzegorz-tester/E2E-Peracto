@regression
Feature: Basket interactions

  # CONFIRMED live 2026-09-23: unlike most of this suite's Keylite clicks,
  # the basket's own controls (quantity +/-, remove, promo code Apply) all
  # respond to a normal click - no JS-dispatch needed. Quantity "-" is
  # disabled at 1, so decrementing below 1 isn't possible (remove is the
  # only way to empty a line).
  #
  # Promo code: the "Add a promotional code?" toggle and the "Apply"
  # button are the SAME testid (add-promotion-form__button) - the toggle
  # re-renders into the form's submit button once clicked - so "promo code
  # apply button" is additionally scoped to [type='submit'].
  #
  # The valid-code scenario depends on real staging data: 20SKI2025 is one
  # of Keylite's own "Engineer Discount" promotions (Peracto Admin >
  # Promotions, id 39) - 20% off, manual-entry only, and ONLY for products
  # of sub-type Blind (a window basket gets "The promo code conditions have
  # not been met." instead, confirmed live). If this code is ever retired,
  # pick another active manual-entry Engineer Discount code from that list
  # rather than creating a new promotion just for this test.

  Background:
    Given I am navigating the page as a "guest" user

  Scenario: Changing the quantity of a basket item updates its total correctly
    Given I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "quantity input" should equal the value "1"
    When I increment the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "2"
    And the basket sub total should equal the sum of all basket line totals
    When I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"

  Scenario: Removing the only item empties the basket
    Given I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "basket item" should be displayed
    When I click on the "remove basket line" button
    Then the "basket item" should not be displayed
    And the "no items message" should contain the text "You have no items in your basket."

  Scenario: An invalid promo code is rejected with an error message
    Given I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    When I click on the "promo code toggle" button
    And I fill in the "promo code input" input field with "INVALIDCODE123"
    And I click on the "promo code apply button" button
    Then the "promo code message" should contain the text "This is not a valid promo code."
    And the "basket total" price should equal the "basket subtotal" price

  Scenario: A valid engineer promo code takes 20% off a blind, and removing it restores the total
    Given I navigate directly to the path "/products/blackout-blinds"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "Use Product Size" element via JavaScript
    Then the "size serial number" should be displayed
    When I dismiss the newsletter popup if present
    And I fill in the "size serial number" input field with "1100160000014"
    And I click on the "1st" "configurator next step" element via JavaScript, retrying until the "configurator options" is displayed
    # Same step sequence as blinds-configurator.feature, popup dismissals
    # included - they double as the wait for each step's options to render
    # (dropping them fails on the 3rd step with no options found yet).
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    Then the "configurator review product name" should be displayed
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator add to basket" element via JavaScript
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "basket item name" should contain the text "Blackout Blinds"
    And the "basket total" price should equal the "basket subtotal" price

    When I click on the "promo code toggle" button
    And I fill in the "promo code input" input field with "20SKI2025"
    And I click on the "promo code apply button" button
    Then the "applied promo badge" should contain the text "20SKI2025"
    And the "basket discount" should be displayed
    And the "basket total" price should be "20"% less than the "basket subtotal" price

    When I click on the "remove applied promo" button
    Then the "applied promo badge" should not be displayed
    And the "basket total" price should equal the "basket subtotal" price

  Scenario: Quick Buy search in the basket finds a real product and opens its page
    Given I am on the "basket" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I fill in the "quick buy search" input field with "ray.lux"
    Then the "quick buy results" should be displayed
    And the "quick buy first result" should contain the text "ray.lux"
    When I click on the "1st" "quick buy first result" element via JavaScript
    Then I should be redirected to the "pdp" page
