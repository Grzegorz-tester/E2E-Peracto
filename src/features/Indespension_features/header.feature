@regression
Feature: Header functionality


  Scenario: Verify presence of header elements for a Guest user
    Given I am navigating the page as a "guest" user
    Then the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "VAT toggle" should be displayed
    And the "Sign In button" should be displayed
    And the "user name" should not be displayed
    And the "Sign Out button" should not be displayed


  # CONFIRMED SITE BEHAVIOUR (live, 2026-08-21): the VAT toggle only renders
  # for guests - a logged-in account customer always sees Excl. VAT pricing
  # with no toggle at all (0 matches for [data-testid='switch__indicator']
  # once signed in). The previous version of this scenario expected it
  # displayed for a logged-in user too and simply timed out.
  Scenario: Verify presence of header elements for a Logged-in user
    Given I am navigating the page as a "logged in" user
    Then the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "VAT toggle" should not be displayed
    And the "user name" should be displayed
    And the "Sign Out button" should be displayed
    And the "Sign In button" should not be displayed


  # "Download Catalogue" previously asserted a redirect to
  # "technical-documents" - that's a different link entirely (in the
  # footer). The header icon's real href is /catalogues, confirmed live.
  Scenario Outline: Verify redirection from header icons
    Given I am on the "<page>" page
    When I click on the "<icon>" icon
    Then I should be redirected to the "<redirection>" page

    Examples:
      | page | icon               | redirection |
      | home | Branch Finder      | branches    |
      | home | Download Catalogue | catalogues  |
      | home | Basket             | basket      |


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
    And the "products amount" should contain the text "can't find any results"

    Examples:
      | product name         | title                |
      | non existent product | non existent product |


  # Replaced the previous "Marine Trailer" -> coasterNanoMarineTrailer
  # example - that exact PDP no longer exists; confirmed live the same
  # search term now resolves to a different marine trailer SKU.
  Scenario Outline: Verify search box functionality using Algolia autocomplete
    Given I am on the "home" page
    When I fill in the "Search bar" input field with "<product name>"
    Then the "search results" should be displayed
    When I click on the "1st" "search result" element
    Then I should be redirected to the "<product>" page

    Examples:
      | product name   | product         |
      | Marine Trailer | marineTrailerPdp |


  # Previously only tested 3 of the drawer's 7 real items (Towbars was
  # commented out); the other 3 (Trailer Hire, Offers, Services) weren't
  # tested at all. Extended to the full, live nav - confirmed 2026-08-21.
  Scenario Outline: Verify redirection from menu elements in the header
    Given I am on the "home" page
    When I click on the "Menu" icon
    And I click on the "<menu element>" element
    Then I should be redirected to the "<redirection>" page

    Examples:
      | menu element  | redirection    |
      | Trailers      | trailers       |
      | Trailer Parts | trailer-parts  |
      | Trailer Hire  | trailer-hire   |
      | Towbars       | towbars        |
      | Offers        | special-offers |
      | Services      | services       |
      | Used Trailers | used-trailers  |
