
Feature: Header functionality


  Scenario: Verify menu elements
    Given I am on the "home" page
    Then the "Building Materials menu item" should be displayed
    Then the "Bricks & Blocks menu item" should be displayed
    Then the "Roofing menu item" should be displayed
    Then the "Tools & Workwear menu item" should be displayed
    Then the "Painting & Decorating menu item" should be displayed
    Then the "Timber & Sheet menu item" should be displayed
    Then the "Doors & Flooring menu item" should be displayed
    Then the "Landscaping & Gardening menu item" should be displayed
    Then the "Plumbing & Heating menu item" should be displayed
    Then the "Bathrooms & Kitchens menu item" should be displayed
    Then the "Special Offers menu item" should be displayed
    Then the "Clearance menu item" should be displayed


  Scenario: Verify "Sign In" functionality
    Given I am on the "home" page
    When I click on the "Sign In" icon
    Then I should be redirected to the "login" page


  Scenario Outline: Verify search box functionality using the Magnifier glass button
    Given I am on the "home" page
    When I fill in the "Search our products..." input field with "<product name>"
    And I click on the "magnifier glass" element
    Examples:
      | product name  | category name    | title |
      | Brick Oatmeal | Bathroom mirrors | SOLAS |


  Scenario Outline: Verify search box functionality using the Algolia search results prompt in the header
    Given I am on the "home" page
    When I fill in the "Search our products..." input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "first search result" element
    Then I should be redirected to the "<product page>" page
    Examples:
      | product name  | product page  |
      | Brick Oatmeal | Oatmeal brick |