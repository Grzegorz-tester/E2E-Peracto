@regression
Feature: Basket

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. The basket line's "Update" button is genuinely disabled
  # until the quantity input's value changes - a click on it beforehand
  # (even forced) is a silent no-op, since a disabled native form control
  # doesn't submit regardless of how the click was dispatched. Explicitly
  # waiting for it to report enabled first (as below) avoids that trap.

  Scenario: An empty basket shows the empty-basket message
    Given I am on the "basket" page
    And I click on the "Accept cookies" button if present
    Then the "empty basket message" should be displayed

  Scenario: Adding a product, updating its quantity and removing it all update the basket correctly
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    Then the "basket item title" should be displayed
    And I remember the text of "basket line total price" as "line total before"
    And I remember the text of "Order total" as "order total before"

    When I click on the "basket quantity increase" element
    Then the "Update basket" should be enabled
    When I click on the "Update basket" button
    Then the "basket line total price" text should not equal the remembered "line total before"
    And the "Order total" text should not equal the remembered "order total before"

    When I click on the "remove basket line" element
    Then the "basket item title" should not be displayed
    And the "empty basket message" should be displayed
