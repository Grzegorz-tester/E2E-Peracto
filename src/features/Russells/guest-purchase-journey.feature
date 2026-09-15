@regression
Feature: Purchase journey (Guest)

  # This deliberately completes a real order every run against Russells
  # staging - keep it to one run per suite execution. Checkout test data is
  # tagged as a Velstar test, per this repo's convention.

  @smoke @places-real-order
  Scenario: Guest can complete a real order end-to-end
    Given I require staging for this scenario
    And I navigate directly to the path "/products/walterscheid-universal-joint-32-x-76mm-standard-duty"
    And I click on the "Accept cookies" button if present
    And I remember the text of "product name" as "product name"
    And I remember the text of "product SKU" as "product sku"
    And I click on the "Add to Basket" button

    When I am on the "basket" page
    Then the "basket item" should be displayed
    And I remember the text of "basket item price" as "product price"
    When I click on the "Checkout" button

    Then I should be redirected to the "checkout-sign-in" page
    When I click on the "Guest checkout radio" button
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Continue as guest" button

    Then I should be redirected to the "checkout-delivery-method" page
    When I click on the "Delivery option" button
    And I click on the "Delivery method continue" button

    Then I should be redirected to the "checkout-delivery" page
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "221B Baker Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "NW1 6XE"
    And I click on the "Guest address submit" button

    Then the "delivery phone" should be displayed
    When I fill in the "delivery phone" input field with "07700900000"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button

    Then I should be redirected to the "checkout-payment-method" page
    When I click on the "Pay with Card" button

    Then I should be redirected to the "checkout-billing" page
    When I check the "billing same as delivery"
    And I click on the "billing continue" button

    Then I should be redirected to the "checkout-review" page
    And I remember the text of "review shipping cost" as "shipping cost"
    When I check the "review terms and conditions"
    And I click on the "Continue to Payment" button
    And I pay with the "default" GlobalPayments test card

    Then I should be redirected to the "thank-you" page
    And the "Order reference" should contain the text "Order No."
    And the "Order confirmation email" should contain the stored guest email
    And the "Order line" should be displayed
    And the "Order line name" text should equal the remembered "product name"
    And the "Order line SKU" should contain the remembered "product sku"
    And the "Order line quantity" should equal text "1"
    And the "Order line price" text should equal the remembered "product price"
    And the "Order line total price" text should equal the remembered "product price"
    And the "Order delivery method" should contain the text "DPD"
    And the "Order delivery address" should contain the text "Velstar Test"
    And the "Order delivery address" should contain the text "221B Baker Street"
    And the "Order delivery address" should contain the text "London"
    And the "Order delivery address" should contain the text "NW1 6XE"
    And the "Order delivery address" should contain the text "07700900000"
    And the "Order summary subtotal" text should equal the remembered "product price"
    And the "Order summary shipping total" text should equal the remembered "shipping cost"
    And the "Order summary total" should be displayed
    And the "Order payment details" should contain the text "Payment Method"
    And the "Order payment details" should contain the text "Billing Address"
