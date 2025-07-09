@Panelco_regression

Feature: Header functionality

#------------ Top header ---------------------------------

  Scenario: Verify:
  - presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    Then the "contact phone number" should be displayed
    And the "contact email" should be displayed
    And the "Sign In" should be displayed
    And the "Sign Out" should not be displayed

    And the "Quote" should be displayed
    And the "Trade" should be displayed
    And the "Portal" should be displayed
    And the "Samples" should be displayed


  Scenario: Verify:
  - presence of header elements for a Logged in user
    Given I am navigating the page as a "logged in" user
    Then the "contact phone number" should be displayed
    And the "contact email" should be displayed
    And the "Sign In" should not be displayed
    And the "Sign Out" should be displayed

    And the "Quote" should be displayed
    And the "Trade" should be displayed
    And the "Portal" should be displayed
    And the "Samples" should be displayed

#  ------------ Middle header ---------------------------------


  Scenario: Verify:
  - "Quote" redirection
    Given I am on the "home" page
    When I click on the "Quote" icon
    Then I should be redirected to the "quote" page


  Scenario: Verify:
  - "Trade" redirection
    Given I am on the "home" page
    When I click on the "Trade" icon
    Then I should be redirected to the "trade-account-application" page


  Scenario: Verify:
  - "Samples" redirection
    Given I am on the "home" page
    When I click on the "Portal" icon
    Then I should be redirected to the "login" page


  Scenario: Verify:
  - "Portal" redirection
    Given I am on the "home" page
    When I click on the "Samples" icon
    Then I should be redirected to the "samples" page


  Scenario Outline: Verify:
  - search box functionality using the Magnifier glass button for existing products
    Given I am on the "home" page
    When I fill in the "Search products" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should be displayed
    Examples:
      | product name        | title               |
      | EGGER Glacier White | EGGER GLACIER WHITE |


  Scenario Outline: Verify:
  - search box functionality using the Magnifier glass button for NOT existing products
    Given I am on the "home" page
    When I fill in the "Search products" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "no results message" should contain the text "<message>"
    And the "products amount" should contain the text "0"
    Examples:
      | product name         | title                | message                                                 |
      | non existent product | NON EXISTENT PRODUCT | Sorry, no results could be found for this search query. |


  Scenario Outline: Verify:
  - search box functionality using the Algolia search results autocomplete in the header
    Given I am on the "home" page
    When I fill in the "Search products" input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | product name        | product             |
      | EGGER Glacier White | egger-glacier-white |


#  Scenario Outline: Verify:
#  - search box functionality using the Algolia search results autocomplete in the menu side-draw
#    Given I am on the "home" page
#    When I click on the "Menu" button
#    Then the "menu draw" should be displayed
#    When I fill in the "Search products - draw" input field with "<product name>"
#    When I click on the "first search result" element
#    Then I should be redirected to the "<product>" page
#    Examples:
#      | product name        | product             |
#      | EGGER Glacier White | egger-glacier-white |


#  Scenario Outline: Verify redirection to menu elements
#    Given I am on the "home" page
#    When I click on the "<menu element>" element
#    Then I should be redirected to the "<page>" page
#    And the "page title" should contain the text "<title>"
#    Examples:
#      | menu element                  | page              | title |
#      | Products menu item            |                   |       |
#      | Brands menu item              |                   |       |
#      | Design Facilities menu item   | design-facilities |       |
#      | Help & Advice menu item       |                   |       |
#      | Ideas & Inspiration menu item |                   |       |