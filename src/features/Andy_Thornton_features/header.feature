@Andy_Thornton_regression
Feature: Header functionality

  Scenario: Verify presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    Then the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "Sign In button" should be displayed
    And the "user name" should not be displayed
    And the "Sign Out button" should not be displayed

  Scenario: Verify menu elements
    Given I am on the "home" page
    Then the "Contract Furniture menu item" should be displayed
    And the "By Venue menu item" should be displayed
    And the "Interior Fittings & Antiques menu item" should be displayed
    And the "Architectural Metalwork menu item" should be displayed
    And the "Projects menu item" should be displayed
    And the "More menu item" should be displayed

  Scenario: Verify the Basket icon redirects to the basket page
    Given I am on the "home" page
    When I click on the "Basket icon" icon
    Then I should be redirected to the "basket" page

  Scenario: Verify the Moodboards icon requires sign-in for a Guest user
    Given I am on the "home" page
    When I click on the "Moodboards icon" icon
    Then I should be redirected to the "login" page

  Scenario Outline: Verify search box functionality using the Algolia search results dropdown
    Given I am on the "home" page
    When I fill in the "Search products" input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | product name              | product |
      | Vienna Stackable Side Chair | pdp   |

  Scenario Outline: Verify search box functionality using the Magnifier glass button
    Given I am on the "home" page
    When I fill in the "Search products" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    Examples:
      | product name              |
      | Vienna Stackable Side Chair |
