@smoke

Feature: Product purchase flow


  Scenario Outline: Successful product purchase
    Given I am on the "home" page
    When I click on the "Cookie OK" button
    And I click on the "Sign In" link
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "SIGN IN" button
    Then I should be redirected to the "account" page
    When I fill in the "Search our products..." input field with "<product>"
    And I click on the "first search result" element
    Then I should be redirected to the "Oatmeal brick" page
    And the "product price" should be displayed
    When I slowly click on the "DELIVERY" button
    Then the "CHECKOUT" should be displayed
    And I slowly click on the "CHECKOUT" button
    Then I should be redirected to the "basket" page
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
      | g.hajduk@9xb.com | Testing123 | Brick Oatmeal | £16.00      | £2.00          |
