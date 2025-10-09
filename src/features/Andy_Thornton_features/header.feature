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
    And the "Antiques menu item" should be displayed
    And the "Interior Fittings menu item" should be displayed
    And the "Architectural Metalwork menu item" should be displayed
    And the "Projects menu item" should be displayed
    And the "Inspiration menu item" should be displayed
    And the "More menu item" should be displayed


  Scenario: Verify menu icons redirection
    Given I am navigating the page as a "logged in" user
    When I click on the "Quotes" icon
    Then I should be redirected to the "quotes" page
    When I click on the "Back to Store" button
    Then I should be redirected to the "home" page
    When I click on the "Account" icon
    Then I should be redirected to the "account" page
    When I click on the "Back to Store" button
    Then I should be redirected to the "home" page
    When I click on the "Basket" icon
    Then I should be redirected to the "basket" page

  Scenario Outline: Verify search box functionality using the Magnifier glass button
    Given I am on the "home" page
    When I fill in the "Search..." input field with "<product name>"
    And I click on the "magnifier glass" element
    Examples:
      | product name     | category name    | title |
      | Harrow Bar Stool | Bathroom mirrors | SOLAS |


  Scenario Outline: Verify search box functionality using the Algolia search results prompt in the header
    Given I am on the "home" page
    When I fill in the "Search..." input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | product name     | product |
      | Harrow Bar Stool | pdp     |

