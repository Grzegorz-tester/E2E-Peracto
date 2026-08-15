@regression
Feature: Currency switching
  - GBP is the site's default currency; EUR is the only other option in the
    header currency picker.
  - PLP (category grid) pages currently show no price at all on this site
    (name/image/variant-count only), so PLP is intentionally out of scope
    here - only PDP and the basket, where price is actually shown.


  Scenario: Currency toggle is visible on the site
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    Then the "currency picker" should be displayed


  Scenario: Switching currency updates the PDP price and reverts back
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    Then the "product price" should contain the text "£"
    When I switch the currency to "EUR"
    Then the "product price" should contain the text "€"
    When I switch the currency to "GBP"
    Then the "product price" should contain the text "£"


  Scenario: Switching currency updates the basket price and total, and reverts back
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "place-order" page
    And I fill in the "Search products" input field with "Vanquish"
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's price" should contain the text "£"
    And the "order total price" should contain the text "£"
    When I switch the currency to "EUR"
    Then the "product's price" should contain the text "€"
    And the "order total price" should contain the text "€"
    When I switch the currency to "GBP"
    Then the "product's price" should contain the text "£"
    And the "order total price" should contain the text "£"
