@regression
Feature: Basket interactions

  # Full rewrite - the previous version searched for a product called
  # "Vanquish" (an HIB SKU, not sold here) via an on-page search box that
  # doesn't exist on Indespension's real /basket page, had no @regression/
  # @smoke tag so it never actually ran, and its quantity-change/remove
  # scenarios ended with no assertions at all. Uses a guest session
  # throughout (no login) so the basket is always a fresh, empty one for
  # this browser context - a logged-in account's basket is server-side and
  # persists across runs, which would make "start from empty" unreliable.

  Background:
    # Settle before the first click (2026-09-29): same Next.js hydration race
    # as logging-in/register. Confirmed live on the PDP: clicking Add to
    # Basket straight after load gave no confirmation 3/3 times, and after
    # settling it worked 3/3. A click that lands before hydration does nothing.
    Given I am navigating the page as a "guest" user
    And I am on the "blueline-trailer-pdp" page
    And I wait for the page to settle

  Scenario: Adding a product to the basket
    When I click on the "Add to basket" button
    Then the "added to basket confirmation" should be displayed
    When I press the Escape key
    Then the "basket count" should contain the text "1"

  Scenario: Changing the quantity of a basket item updates its total correctly
    When I click on the "Add to basket" button
    Then the "added to basket confirmation" should be displayed
    When I press the Escape key
    # Precise (non-forced) click (2026-09-28): the added-to-basket dialog's
    # fade-out overlay is still animating after Escape, and a forced click
    # can land on it instead of the header link - the page then stays on
    # the PDP. The non-forced click waits for the overlay to clear.
    And I click precisely on the "Basket" icon
    Then I should be redirected to the "basket" page
    When I increment the basket quantity and the total should update correctly
    And I decrement the basket quantity and the total should update correctly
    Then the "quantity input" should equal the value "1"

  Scenario: Removing a product empties the basket
    When I click on the "Add to basket" button
    Then the "added to basket confirmation" should be displayed
    When I press the Escape key
    # Precise (non-forced) click (2026-09-28): the added-to-basket dialog's
    # fade-out overlay is still animating after Escape, and a forced click
    # can land on it instead of the header link - the page then stays on
    # the PDP. The non-forced click waits for the overlay to clear.
    And I click precisely on the "Basket" icon
    Then I should be redirected to the "basket" page
    When I click on the "Remove items" element
    Then the "no items message" should be displayed
