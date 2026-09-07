@regression
Feature: Payment alternatives and failures

  # Covers two payment paths the purchase-journey scenarios don't touch:
  # the PayPal option offered alongside card payment, and a declined card.
  # Neither test authenticates with PayPal or places a real order - see the
  # PayPal step's own note on why (this integration points at PayPal's
  # production environment even on staging).

  Background:
    Given I navigate directly to the path "/products/walterscheid-universal-joint-32-x-76mm-standard-duty"
    And I click on the "Accept cookies" button if present
    And I click on the "Add to Basket" button
    And I am on the "basket" page
    And I click on the "Checkout" button
    And I click on the "Guest checkout radio" button
    And I fill in the "Guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    And I click on the "Delivery option" button
    And I click on the "Delivery method continue" button
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "221B Baker Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "NW1 6XE"
    And I click on the "Guest address submit" button
    And I fill in the "delivery phone" input field with "07700900000"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button
    Then I should be redirected to the "checkout-payment-method" page

  Scenario: PayPal button opens a popup that redirects to PayPal
    When I click on the "PayPal button" button and verify it opens a popup redirecting to "paypal.com"

  Scenario: A declined card fails gracefully at Review and Pay without losing the order
    When I click on the "Pay with Card" button
    Then I should be redirected to the "checkout-billing" page
    When I check the "billing same as delivery"
    And I click on the "billing continue" button

    Then I should be redirected to the "checkout-review" page
    When I check the "review terms and conditions"
    And I click on the "Continue to Payment" button
    And I pay with the "declined" GlobalPayments test card

    Then the "payment error alert" should contain the text "Sorry, there was an error when processing your payment."
    And I should be redirected to the "checkout-review" page
