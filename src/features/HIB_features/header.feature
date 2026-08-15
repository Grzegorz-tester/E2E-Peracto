@regression

Feature: Header functionality

  #------------ Top header ---------------------------------

  Scenario: Verify:
    - presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    And I dismiss the newsletter popup if present
    Then the "contact phone number" should be displayed
    And the "contact email" should be displayed
    And the "currency picker" should be displayed
    And the "Portal" should be displayed
    And the "basket" should not be displayed

    And the "Request Swatch Sample" should be displayed
    And the "Find a Retailer" should be displayed
    And the "Request a brochures" should be displayed


  Scenario: Verify:
    - presence of header elements for a Logged in user
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    Then the "contact phone number" should be displayed
    And the "contact email" should be displayed
    And the "currency picker" should not be displayed
    And the "Portal" should be displayed
    And the "basket" should be displayed

    And the "Request Swatch Sample" should not be displayed
    And the "Find a Retailer" should be displayed
    And the "Request a brochures" should be displayed

  #  ------------ Middle header ---------------------------------


  Scenario: Verify:
    - "Request Swatch Sample" redirection
    Given I am navigating the page as a "guest" user
    And I dismiss the newsletter popup if present
    When I click on the "Request Swatch Sample" icon
    Then I should be redirected to the "samples" page


  Scenario: Verify:
    - "Find a retailer" redirection
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Find a Retailer" icon
    Then I should be redirected to the "find-a-retailer" page


  Scenario: Verify:
    - "Request a brochures" redirection
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Request a brochures" icon
    Then I should be redirected to the "brochure" page


  Scenario: Verify:
    - "Portal" menu item functionality
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Portal" icon
    Then I should be redirected to the "login" page


  Scenario Outline: Verify:
    - search box functionality using the Magnifier glass button for existing products
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I fill in the "Search products" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should be displayed
    Examples:
      | product name | title |
      | Solas        | SOLAS |


  Scenario Outline: Verify:
    - search box functionality using the Magnifier glass button for NOT existing products
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I fill in the "Search products" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should not be displayed
    And the "no results message" should contain the text "<message>"
    And the "products amount" should contain the text "0"
    Examples:
      | product name         | title                | message                                                 |
      | non existent product | NON EXISTENT PRODUCT | Sorry, no results could be found for this search query. |


  Scenario Outline: Verify:
    - search box functionality using the Algolia search results autocomplete in the header
    - covers both searching by product name and by SKU/article number
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I fill in the "Search products" input field with "<search term>"
    And I wait for the search results to update
    Then the "search results" should be displayed
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | search term | product        |
      | Solas       | solas          |
      | AUCROBK     | auryn-cabinet  |


  Scenario Outline: Verify:
    - search box functionality using the Algolia search results autocomplete in the menu side-draw
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Menu" link
    Then the "menu draw" should be displayed
    When I fill in the "Search products - draw" input field with "<product name>"
    And I wait for the search results to update
    When I click on the "first search result" element
    Then I should be redirected to the "<product>" page
    Examples:
      | product name | product |
      | Solas        | solas   |


  Scenario Outline: Verify redirection to menu elements
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "<menu element>" element
    Then I should be redirected to the "<page>" page
    And the "page title" should contain the text "<title>"
    Examples:
      | menu element          | page        | title       |
      | Inspiration menu item | inspiration | Inspiration |
      | About menu item       | about       | About hib.  |
      | Support menu item     | support     | SUPPORT     |
      | News menu item        | news        | News        |
      | Careers               | careers     |             |