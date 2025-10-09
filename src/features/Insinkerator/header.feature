@regression
Feature: Header functionality

  # ------------ Top header ---------------------------------
 
@dev
  Scenario: Verify presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    Then the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "VAT toggle" should be displayed
    And the "Sign In button" should be displayed
    And the "user name" should not be displayed
    And the "Sign Out button" should not be displayed


  # Scenario: Verify presence of header elements for a Logged-in user
  #   Given I am navigating the page as a "logged in" user
  #   Then the "Contact Us email" should be displayed
  #   And the "contact phone number" should be displayed
  #   And the "VAT toggle" should be displayed
  #   And the "user name" should be displayed
  #   And the "Sign Out button" should be displayed
  #   And the "Sign In button" should not be displayed

  # ------------ Middle header ---------------------------------


  Scenario Outline: Verify redirection from header icons
    Given I am on the "<page>" page
    When I click on the "<icon>" icon
    Then I should be redirected to the "<redirection>" page

    Examples:
      | page | icon               | redirection         |
      | home | Branch Finder      | branches            |
      | home | Download Catalogue | technical-documents |
      | home | Basket             | basket              |


  Scenario Outline: Verify search box functionality for existing products
    Given I am on the "home" page
    When I fill in the "Search bar" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products cards" should be displayed

    Examples:
      | product name  | title         |
      | plant trailer | plant trailer |
      | ISPJ001       | ISPJ001       |


  Scenario Outline: Verify search box functionality for non-existing products
    Given I am on the "home" page
    When I fill in the "Search bar" input field with "<product name>"
    And I click on the "magnifier glass" element
    Then I should be redirected to the "search" page
    And the "title" should contain the text "<title>"
    And the "products amount" should contain the text "0"

    Examples:
      | product name         | title                |
      | non existent product | non existent product |



  Scenario Outline: Verify search box functionality using Algolia autocomplete
    Given I am on the "home" page
    When I fill in the "Search bar" input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "1st" "search result" element
    Then I should be redirected to the "<product>" page

    Examples:
      | product name   | product                  |
      | Marine Trailer | coasterNanoMarineTrailer |

  # ------------ Menu in header ---------------------------------

  Scenario Outline: Verify redirection from menu elements in the header
    Given I am on the "home" page
    When I click on the "<menu element>" element
    Then I should be redirected to the "<redirection>" page
    And the "title" should contain the text "<title>"

    Examples:
      | menu element  | redirection   | title         |
      | Trailers      | trailers      | Trailers      |
      | Used Trailers | used-trailers | Used Trailers |
      | Trailer Parts | trailer-parts | Trailer Parts |
  # | Towbars       | towbars       | Towbars       |

  # ------------ USP header elements ---------------------------------

  Scenario Outline: Verify redirection from USP elements in the header
    Given I am on the "home" page
    When I click on the "<menu element>" element
    Then I should be redirected to the "<redirection>" page
    And the "title" should contain the text "<title>"

    Examples:
      | menu element  | redirection   | title         |
      | Trailers      | trailers      | Trailers      |
      | Used Trailers | used-trailers | Used Trailers |
      | Trailer Parts | trailer-parts | Trailer Parts |