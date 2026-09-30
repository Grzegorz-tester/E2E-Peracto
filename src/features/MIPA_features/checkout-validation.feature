@regression
Feature: Checkout validation

  # CONFIRMED live 2026-09-25 on feature-next-15 - how MIPA's checkout holds
  # back incomplete input (none of these scenarios place an order; the only
  # order-placing checkout coverage is customer-flow.feature and
  # quick-order.feature):
  # - Two delivery methods: "Delivery" and "Click & Collect". Click & Collect
  #   offers a single collection point (Mipa Paints Ltd, Havant), and
  #   Continue stays disabled until it's ticked. Continuing then shows a
  #   "Your selected collection branch" step (optional collection note,
  #   Collection Options) before Billing.
  # - On the Delivery path, Continue stays disabled until a shipping option
  #   is chosen.
  # - On Review & Pay, PLACE ORDER stays disabled until BOTH the required
  #   Purchase Order Ref Number is filled AND the terms and conditions box
  #   is ticked - either on its own isn't enough. No inline error messages
  #   are shown; the button simply stays disabled.

  Background:
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    And I wait for the page to settle
    When I click on the "Checkout" button
    Then I should be redirected to the "checkout" page


  Scenario: Click & Collect needs a collection point before checkout can continue
    When I click on the "Click & Collect method" element
    And I click on the "Continue" button
    Then the "collection point" should be displayed
    And the "Continue" should not be enabled
    When I click on the "collection point checkbox" element
    Then the "Continue" should be enabled
    When I click on the "Continue" button
    Then the "selected collection branch" should be displayed


  Scenario: Delivery needs a shipping option before checkout can continue
    When I click on the "Delivery method" element
    And I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    Then the "Continue" should not be enabled
    When I click on the "Courier delivery option" element
    Then the "Continue" should be enabled


  Scenario: PLACE ORDER needs both a PO number and the terms and conditions
    When I click on the "Delivery method" element
    And I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    And I click on the "Courier delivery option" element
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    Then the "PO Number" should be displayed
    And the "PLACE ORDER" should not be enabled
    When I fill in the "PO Number" input field with "Velstar Test"
    Then the "PLACE ORDER" should not be enabled
    When I fill in the "PO Number" input field with ""
    And I click on the "Terms and conditions checkbox" element
    Then the "PLACE ORDER" should not be enabled
    When I fill in the "PO Number" input field with "Velstar Test"
    Then the "PLACE ORDER" should be enabled
