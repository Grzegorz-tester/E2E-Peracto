@regression
Feature: Product Listing Page (PLP)

  Scenario: PLP loads with products displayed correctly
    Given I am on the "products" page
    And I dismiss the newsletter popup if present
    Then the "PLP hit count" should be displayed
    And the "PLP product cards" should be displayed
    And the "PLP product card" should be displayed

  Scenario: Clicking a product on the PLP navigates to its own PDP
    Given I am on the "products" page
    And I dismiss the newsletter popup if present
    When I click on the "1st" "PLP view product" element
    Then the current URL should contain "/products/"

  Scenario: Pagination loads additional results
    Given I am on the "products" page
    And I dismiss the newsletter popup if present
    When I click on the "PLP pagination next" element
    Then the "PLP product cards" should be displayed
