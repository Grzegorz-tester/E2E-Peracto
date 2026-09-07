@regression
Feature: Purchase journey (Logged-in)

  # This deliberately completes a real order every run against Russells
  # staging - keep it to one run per suite execution. account-orders.feature
  # depends on this having run first. Relies on the "logged in" test
  # account's permanent fixture delivery/billing address to select at
  # checkout.

  @smoke @places-real-order
  Scenario: Logged-in user can complete a real order end-to-end
    Given I am navigating the page as a "logged in" user
    And I click on the "Accept cookies" button if present
    And I am on the "basket" page
    And I clear the basket

    When I am on the "home" page
    And I choose the "General Parts" category from the menu
    And I click on the sub-category tile for "general-parts-pto-driveline-components"
    Then I should be redirected to the "category" page

    When I click on the "1st" "product card" element
    Then I should be redirected to the "products" page
    And I remember the text of "product name" as "product name"
    And I remember the text of "product SKU" as "product sku"
    And I click on the "Add to Basket" button

    When I navigate directly to the path "/basket"
    Then the "basket item" should be displayed
    And I remember the text of "basket item price" as "product price"
    When I click on the "Checkout" button

    Then I should be redirected to the "checkout-delivery-method" page
    When I click on the "Delivery option" button
    And I click on the "Delivery method continue" button

    Then I should be redirected to the "checkout-delivery" page
    When I click on the "1st" "saved address option" element
    And I click on the "delivery continue" button

    Then the "delivery phone" should be displayed
    When I fill in the "delivery phone" input field with "07700900000"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button

    Then I should be redirected to the "checkout-payment-method" page
    When I click on the "Pay with Card" button

    Then I should be redirected to the "checkout-billing" page
    When I click on the "1st" "saved address option" element
    And I click on the "delivery continue" button

    Then I should be redirected to the "checkout-review" page
    And I remember the text of "review shipping cost" as "shipping cost"
    When I check the "review terms and conditions"
    And I click on the "Continue to Payment" button
    And I pay with the "default" GlobalPayments test card

    Then I should be redirected to the "thank-you" page
    And the "Order reference" should contain the text "Order No."
    And the "Order confirmation email" should contain the "logged in" user's email
    And the "Order line" should be displayed
    And the "Order line name" text should equal the remembered "product name"
    And the "Order line SKU" should contain the remembered "product sku"
    And the "Order line quantity" should equal text "1"
    And the "Order line price" text should equal the remembered "product price"
    And the "Order line total price" text should equal the remembered "product price"
    And the "Order delivery method" should contain the text "DPD"
    And the "Order delivery address" should contain the text "07700900000"
    And the "Order summary subtotal" text should equal the remembered "product price"
    And the "Order summary shipping total" text should equal the remembered "shipping cost"
    And the "Order payment details" should contain the text "Payment Method"

    When I remember the text of "Order reference" with the prefix "Order No." stripped, as "order reference"
    And I am on the "account-orders" page
    And I fill in the "Order reference filter" input field with the remembered "order reference"
    And I click on the "first order row" element
    Then I should be redirected to the "account-order-detail" page
    And the "Order line name" text should equal the remembered "product name"
    And the "Order summary subtotal" text should equal the remembered "product price"
