@Andy_Thornton_regression

Feature: Product purchase flow


  Scenario Outline: Successful product purchase
    Given I am on the "home" page
    When I click on the "Sign In" icon
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with "<email>"
    And I fill in the "Password" input field with "<password>"
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
    When I click on the "Back to Store" button
    When I fill in the "Search..." input field with "<product>"
    And I click on the "first search result" element
    And I click on the "Add to basket" button
    Then I should be redirected to the "basket-success" page
    When I click on the "Proceed to checkout" button
    Then I should be redirected to the "checkout" page
    When I click on the "PROCEED" button
    And I click on the "Add address" button
    And I fill in the "First Name" input field with "<first name>"
    And I fill in the "Last Name" input field with "<last name>"
    And I click on the "Manually enter your address" button
    And I fill in the "Address Line 1" input field with "<address line 1>"
    And I fill in the "Town/City" input field with "<town/city>"
    And I fill in the "Postcode" input field with "<post code>"
    And I click on the "ADD ADDRESS" button
    And I click on the "first address" element
    And I fill in the "Enter your contact number" input field with "<contact number>"
    And I fill in the "Delivery instructions" input field with "test instructions"
    And I click on the "PROCEED" button
    And I click on the "Delivery Options ( free )" element
    And I click on the "PROCEED" button
    And I click on the "Same as Delivery Address" element
    And I click on the "PROCEED" button
    And I click on the "I accept the terms and conditions" element
    And I click on the "PROCEED" button
#    And I click on the "Continue" button
#    When I fill in the "Phone" input field with "07377777777"
#    And I click on the "Continue" button
#    And I click on the "Billing Address" element
#    And I click on the "Continue" button
#    And I click on the "Continue To Payment" button
#    Then I should be redirected to the "thank-you" page
#    And the "basket header title" should contain the text "Thank you for your order"
#    And the "order total price" should equal text "<total price>"
#    And the "delivery price" should equal text "<delivery price>"

    Examples:
      | email            | password   | product          | first name | last name | post code | address line 1 | town/city | contact number | total price | delivery price |
      | g.hajduk@9xb.com | Testing123 | Harrow Bar Stool | Bob        | Smith     | LS10 1AD  | test line      | test city | 07966666666    | £16.00      | £2.00          |
