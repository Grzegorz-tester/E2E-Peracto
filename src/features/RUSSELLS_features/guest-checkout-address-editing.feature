@regression
Feature: Guest checkout address editing

  # Covers editing the delivery/billing addresses entered during guest
  # checkout, via the two real edit entry points: the delivery summary's
  # own "Change address" button, and the Review & Pay page's per-address
  # "Edit" links. Neither scenario completes a real purchase - both stop
  # before payment, which editing an address doesn't need.

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

  Scenario: Guest can edit their delivery address via its own Change address button
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "221B Baker Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "NW1 6XE"
    And I click on the "Guest address submit" button

    Then the "delivery phone" should be displayed
    When I click on the "delivery change address" button
    And I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "1 Deansgate"
    And I fill in the "address city" input field with "Manchester"
    And I fill in the "address postcode" input field with "M1 1AE"
    And I click on the "Guest address submit" button

    Then the "current delivery address" should contain the text "Manchester"
    And the "current delivery address" should contain the text "M1 1AE"
    When I fill in the "delivery phone" input field with "07700900000"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button
    Then I should be redirected to the "checkout-payment-method" page

  Scenario: Guest can edit their billing address from the Review and Pay page
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I fill in the "address line 1" input field with "221B Baker Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "NW1 6XE"
    And I click on the "Guest address submit" button
    And I fill in the "delivery phone" input field with "07700900000"
    And I click on the "1st" "delivery method option" element
    And I click on the "delivery options continue" button

    Then I should be redirected to the "checkout-payment-method" page
    When I click on the "Pay with Card" button

    Then I should be redirected to the "checkout-billing" page
    When I fill in the "address first name" input field with "Billy"
    And I fill in the "address last name" input field with "Payer"
    And I fill in the "address line 1" input field with "10 Downing Street"
    And I fill in the "address city" input field with "London"
    And I fill in the "address postcode" input field with "SW1A 2AA"
    And I click on the "Guest address submit" button

    Then I should be redirected to the "checkout-review" page
    And the "review delivery address summary" should contain the text "Velstar Test"
    And the "review delivery address summary" should contain the text "NW1 6XE"
    And the "review billing address summary" should contain the text "Billy Payer"
    And the "review billing address summary" should contain the text "SW1A 2AA"

    When I click on the "review billing edit link" link
    Then I should be redirected to the "checkout-billing" page
    When I fill in the "address first name" input field with "Billy"
    And I fill in the "address last name" input field with "Payer"
    And I fill in the "address line 1" input field with "1 Victoria Street"
    And I fill in the "address city" input field with "Birmingham"
    And I fill in the "address postcode" input field with "B1 1AA"
    And I click on the "Guest address submit" button

    Then I should be redirected to the "checkout-review" page
    And the "review billing address summary" should contain the text "Billy Payer"
    And the "review billing address summary" should contain the text "B1 1AA"
