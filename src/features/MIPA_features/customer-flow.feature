@smoke
@MIPA_regression
Feature: Product purchase flow


  Scenario Outline: Successful product purchase
    Given I am on the "home" page
    When I click on the "Portal" icon
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
    When I click on the "header logo" element
    Then I should be redirected to the "home" page
    When I fill in the "Search products" input field with "<product>"
    And I click on the "first search result" element
    Then I should be redirected to the "solas" page
    And I click on the "first variant" button
    And I click on the "Add to basket" button
    And I click on the "Place Order" button
    Then I should be redirected to the "place-order" page
    When I click on the "PLACE ORDER" button
    And I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    When I fill in the "Phone" input field with "07377777777"
    When I fill in the "PO Number" input field with "1"
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    And I click on the "PLACE ORDER" button
    Then I should be redirected to the "thank-you" page
    And the "basket header title" should contain the text "Thank you for your order"
    And the "order total price" should equal text "<total price>"
    And the "delivery price" should equal text "<delivery price>"

    Examples:
      | email            | password   | product | total price | delivery price |
      | g.hajduk@9xb.com | Testing123 | Solas   | £546.00     | £10.00         |
