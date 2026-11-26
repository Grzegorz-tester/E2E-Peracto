@regression @mutates-admin-data
Feature: Viewing an order and updating its status

  # IND-729 (Peracto API upgrade) case 320. Indespension-only for now; not yet
  # checked on other Peracto Admin tenants, so not in CARBON_ADMIN_SHARED_features.
  #
  # CONFIRMED 2026-11-13 (staging-peracto): the order list links each
  # reference to /orders/<id>. The View Order page has no data-testids, so
  # mappings are anchored on its card ids (#items, #transactions...) and row
  # labels. Its status picker is a "list" react-select. "Update Order Status"
  # sends PUT /orders/<id> and shows an "Order status updated!" toast.
  #
  # Uses an existing Processing order (normally one placed by our own
  # logged-in purchase journey), moves it to Packing, then puts it back to
  # Processing, so nothing is left changed. A status change may email the
  # order's customer; on staging those are Velstar test addresses.

  Background:
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Orders" element
    And I click precisely on the "Reset" element
    And I select the "Processing" option from the "Status" react-select
    And I click precisely on the "Apply" element
    And I wait for the page to settle

  Scenario: An order's detail page matches its list row
    When I remember the text of "First order" as "order reference"
    And I remember the price in "first order total" as "list total"
    And I click precisely on the "first order link" element
    Then I should be redirected to the "order-detail" page
    And the "order id" should contain the remembered "order reference"
    And the "order item name" should not equal text ""
    And the "order shipping address" should be displayed
    And the "order shipping service" should not equal text ""
    And the price in "order paid by customer" should equal the remembered "list total"
    And the price in "order transaction amount" should equal the remembered "list total"

  Scenario: Updating an order's status persists after a reload, and can be restored
    When I click precisely on the "first order link" element
    Then I should be redirected to the "order-detail" page
    When I select the "Packing" option from the "Order Status select" react-select
    And I click precisely on the "Update Order Status" button
    Then the "success toast" should be displayed
    When I reload the page
    Then the "selected order status" should equal text "Packing"
    When I select the "Processing" option from the "Order Status select" react-select
    And I click precisely on the "Update Order Status" button
    Then the "success toast" should be displayed
    When I reload the page
    Then the "selected order status" should equal text "Processing"
