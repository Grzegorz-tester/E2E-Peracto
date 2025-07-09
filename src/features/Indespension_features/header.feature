@regression

Feature: Header functionality

#------------ Top header ---------------------------------

  Scenario: Verify:
  - presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    Then the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "VAT toggle" should be displayed
    And the "Sign In button" should be displayed

    And the "user name" should not be displayed
    And the "Sign Out button" should not be displayed


  Scenario: Verify:
  - presence of header elements for a Logged in user
    Given I am navigating the page as a "logged in" user
    Then the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "VAT toggle" should be displayed
    And the "user name" should be displayed
    And the "Sign Out button" should be displayed

    And the "Sign In button" should not be displayed


#  ------------ Middle header ---------------------------------

  Scenario: Verify:
  - "Branch Finder" redirection
    Given I am on the "home" page
    When I click on the "Branch Finder" icon
    Then I should be redirected to the "branches" page


  Scenario: Verify:
  - "Download Catalogue" redirection
    Given I am on the "home" page
    When I click on the "Download Catalogue" icon
    Then I should be redirected to the "download-catalogue" page


  Scenario: Verify:
  - "Basket" redirection
    Given I am navigating the page as a "guest" user
    When I click on the "Basket" icon
    Then I should be redirected to the "basket" page


  Scenario Outline: Verify:
  - search box functionality using the Magnifier glass button for existing products
    Given I am on the "home" page
    When I fill in the "Search products" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should be displayed
    Examples:
      | product name | title |
      |              |       |


#  Scenario Outline: Verify:
#  - search box functionality using the Magnifier glass button for NOT existing products
#    Given I am on the "home" page
#    When I fill in the "Search products" input field with "<product name>"
#    And I click on the "magnifier glass" element
#    Then I should be redirected to the "search" page
#    And the "title" should contain the text "<title>"
#    And the "products cards" should not be displayed
#    And the "no results message" should contain the text "<message>"
#    And the "products amount" should contain the text "0"
#    Examples:
#      | product name         | title                | message                                                 |
#      | non existent product | NON EXISTENT PRODUCT | Sorry, no results could be found for this search query. |
#
#
#  Scenario Outline: Verify:
#  - search box functionality using the Algolia search results autocomplete in the header
#    Given I am on the "home" page
#    When I fill in the "Search products" input field with "<product name>"
#    Then the "search results" should be displayed
#    When I click on the "first search result" element
#    Then I should be redirected to the "<product>" page
#    Examples:
#      | product name | product |
#      | Solas        | solas   |
#
#
#  Scenario Outline: Verify:
#  - search box functionality using the Algolia search results autocomplete in the menu side-draw
#    Given I am on the "home" page
#    When I click on the "Menu" link
#    Then the "menu draw" should be displayed
#    When I fill in the "Search products - draw" input field with "<product name>"
#    When I click on the "first search result" element
#    Then I should be redirected to the "<product>" page
#    Examples:
#      | product name | product |
#      | Solas        | solas   |
#
#
#  Scenario Outline: Verify redirection to menu elements
#    Given I am on the "home" page
#    When I click on the "<menu element>" element
#    Then I should be redirected to the "<page>" page
#    And the "page title" should contain the text "<title>"
#    Examples:
#      | menu element          | page        | title       |
#      | Inspiration menu item | inspiration | INSPIRATION |
#      | About menu item       | about       | ABOUT HiB   |
#      | Support menu item     | support     | SUPPORT     |
#      | News menu item        | news        | News        |
#      | Careers      | careers     |             |