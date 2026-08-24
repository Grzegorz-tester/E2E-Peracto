@MIPA_regression

Feature: Header functionality

#------------ Top header ---------------------------------

  Scenario: Verify:
  - presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    Then the "contact phone number" should be displayed
    And the "contact email" should be displayed
    And the "Sign In" should be displayed
    And the "Sign Out" should not be displayed

    And the "header logo" should be displayed
    And the "Quotes" should be displayed
    And the "Account" should be displayed
    And the "Basket" should be displayed


  Scenario: Verify:
  - presence of header elements for a Logged in user
    Given I am navigating the page as a "logged in" user
    Then the "contact phone number" should be displayed
    And the "contact email" should be displayed
    And the "Sign In" should not be displayed
    And the "Sign Out" should be displayed

    And the "header logo" should be displayed
    And the "Quotes" should be displayed
    And the "Account" should be displayed
    And the "Basket" should be displayed

#  ------------ Middle header ---------------------------------


  Scenario Outline: Verify: - "Quotes" redirection
    Given I am navigating the page as a "<user type>" user
    When I click on the "Quotes" icon
    Then I should be redirected to the "<page type>" page
    Examples:
      | user type | page type |
      | guest     | login     |
      | logged in | quotes    |


  Scenario Outline: Verify: - "Account" redirection
    Given I am navigating the page as a "<user type>" user
    When I click on the "Account" icon
    Then I should be redirected to the "<page type>" page
    Examples:
      | user type | page type |
      | guest     | login     |
      | logged in | account   |


  Scenario Outline: Verify: - "Basket" redirection
    Given I am navigating the page as a "<user type>" user
    When I click on the "Basket" icon
    Then I should be redirected to the "<page type>" page
    Examples:
      | user type | page type |
      | guest     | basket    |
      | logged in | basket    |


  Scenario: Verify: - "Sign In" icon functionality
    Given I am on the "home" page
    When I click on the "Sign In" icon
    Then I should be redirected to the "login" page


  Scenario: Verify: - "Sign Out" icon functionality
    Given I am navigating the page as a "logged in" user
    When I click on the "Sign Out" icon
    Then the "Sign Out" should not be displayed
    And the "Sign In" should be displayed


  Scenario Outline: Verify: - search box functionality using the Magnifier glass button for existing products
    Given I am on the "home" page
    When I fill in the "header search bar" input field with "<product SKU>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should be displayed
    Examples:
      | product SKU | title       |
      | 229510000   | 229510000   |


  Scenario Outline: Verify: - search box functionality using the Magnifier glass button for NOT existing products
    Given I am on the "home" page
    When I fill in the "header search bar" input field with "<product SKU>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should contain the text "<message>"
    And the "products amount" should contain the text "0"
    Examples:
      | product SKU      | title            | message                        |
      | non existent SKU | non existent SKU | Sorry, no products were found. |


  Scenario Outline: Verify: - search box functionality using the Algolia search results autocomplete in the header
    Given I am on the "home" page
    When I fill in the "header search bar" input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | product name          | product |
      | Mipa 2K HS F37 Filler | pdp     |


  Scenario Outline: Verify: - search box functionality using the Algolia search results autocomplete in the menu side-draw
    Given I am on the "home" page
    When I click on the "Menu" link
    Then the "menu draw" should be displayed
    When I fill in the "menu draw search bar" input field with "<product name>"
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | product name          | product |
      | Mipa 2K HS F37 Filler | pdp     |