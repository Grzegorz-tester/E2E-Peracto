@Panelco_regression
Feature: Product purchase flow


  Scenario Outline: Successful product purchase
    Given I am on the "home" page
    When I click on the "Portal" icon
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
    When I click on the "Stock Check & Quick Order" tab
    Then I should be redirected to the "basket" page
    When I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    And I click on the "Checkout securely" button
    Then I should be redirected to the "checkout" page
    When I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    When I fill in the "Phone" input field with "07377777777"
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    And I click on the "Continue To Payment" button
    Then I should be redirected to the "thank-you" page
    And the "basket header title" should contain the text "Thank you for your order"
    And the "order total price" should equal text "<total price>"
    And the "delivery price" should equal text "<delivery price>"

    Examples:
      | email            | password   | product       | total price | delivery price |
      | g.hajduk@9xb.com | Testing123 | Greg's Mirror | £16.00      | £2.00          |
