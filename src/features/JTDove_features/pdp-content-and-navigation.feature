@regression
Feature: Product Detail Page (PDP)

  # New coverage (2026-10-05) against a fixed product so prices stay
  # deterministic: Marine Plywood Sheet (2440 x 1220 x 18mm), product code
  # 310239, £56.98 ex. VAT / £68.38 inc. VAT on staging.

  Scenario: PDP shows the product's details
    Given I am on the "test-product" page
    And I wait for the page to settle
    Then the "product title" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "product SKU" should contain the text "310239"
    And the "product price" should contain the text "£56.98"
    And the "product image" should be displayed
    And the "Quantity input" should equal the value "1"
    And the "DELIVERY" should be displayed
    And the "CLICK & COLLECT" should be displayed
    And the "related products" should be displayed


  Scenario: Changing the quantity updates the PDP total
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click precisely on the "Quantity increment" element
    Then the "Quantity input" should equal the value "2"
    And the "PDP total price" should contain the text "£113.96"
    When I click precisely on the "Quantity decrement" element
    Then the "Quantity input" should equal the value "1"
    And the "PDP total price" should contain the text "£56.98"


  Scenario: Adding to basket for delivery opens the added-to-basket panel
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    And the "added to basket product name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "added to basket quantity" should contain the text "1"
    When I click on the "View basket" element, retrying until redirected to the "basket" page
    Then the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"


  # Branch stock comes from JT Dove's own stock system and loads slowly
  # (8s+ observed on staging), hence the generous wait.
  Scenario: Check branch stock lists branches with their stock levels
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "Check branch stock" element
    Then the "branch stock modal" should be displayed
    And the "first branch stock level" should be displayed within "30" seconds


  Scenario: Click & Collect asks the customer to pick a branch
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "CLICK & COLLECT" button
    Then the "branch stock modal" should be displayed
    And the "Select this branch" should be displayed within "30" seconds
    When I click on the "Select this branch" element
    Then the "added to basket drawer" should be displayed within "15" seconds


  Scenario Outline: The "<section>" information section opens
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "<section> accordion" element
    Then the "open accordion content" should be displayed
    Examples:
      | section        |
      | Specifications |
      | Delivery       |


  # Submitting would email JT Dove staff, so this only checks the form
  # opens with its required fields - it never submits.
  Scenario: Ask A Question opens the product question form
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "Ask A Question" element
    Then the "ask a question modal" should be displayed
    And the "ask a question email" should be displayed
    And the "ask a question phone" should be displayed
    And the "ask a question postcode" should be displayed
    And the "ask a question text" should be displayed
    And the "Submit question" should be displayed


  Scenario: Related products link to their own PDPs
    Given I am on the "test-product" page
    And I wait for the page to settle
    And I remember the text of "first related product name" as "related product"
    # Already on a PDP, so "retrying until redirected to the pdp page" would
    # pass instantly - wait for the URL to leave this product instead.
    When I click on the "first related product" element
    Then the current URL should not contain "2440x1220x18mm-marine-plywood"
    And the "product title" should contain the remembered "related product"


  Scenario: A viewed product appears in Recently Viewed
    Given I am on the "test-product" page
    And I wait for the page to settle
    And the "product title" should be displayed
    When I am on the "plywood" page
    And I wait for the page to settle
    And I am on the "test-product" page
    And I wait for the page to settle
    Then the "recently viewed" should contain the text "Marine Plywood Sheet"
