@regression
Feature: Header functionality

  # CONFIRMED live 2026-09-06: "logged in" lands on "/account"
  # (LOGIN_SUCCESS_URL), which - unlike every other storefront page -
  # renders a stripped-down header with only the logo, no Account/Basket/
  # search bar at all. So both scenarios below navigate to "home" first,
  # to check the normal header a real user browses with, not the one-off
  # account dashboard layout.
  Scenario Outline: Header elements are present for a "<user type>" user
    Given I am navigating the page as a "<user type>" user
    And I am on the "home" page
    And I dismiss the newsletter popup if present
    Then the "header logo" should be displayed
    And the "Account" should be displayed
    And the "Basket" should be displayed
    And the "header search bar" should be displayed

    Examples:
      | user type |
      | guest     |
      | logged in |

  Scenario Outline: "Account" link redirects to the right page for a "<user type>" user
    Given I am navigating the page as a "<user type>" user
    And I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Account" element
    Then I should be redirected to the "<page type>" page

    Examples:
      | user type | page type |
      | guest     | login     |
      | logged in | account   |

  # Confirmed live 2026-09-06: the search dropdown result is a real
  # `<a href>` anchor (algolia-autocomplete-hit-product), but it renders
  # low enough on the page that a real mouse click reports "outside of the
  # viewport" - the same class of issue as the PDP configurator, so this
  # uses the JS-dispatch click variant rather than fighting scroll/viewport
  # positioning.
  Scenario: Header search autocomplete finds a real product
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I fill in the "header search bar" input field with "roof window"
    Then the "search results" should be displayed
    When I click on the "1st" "first search result" element via JavaScript
    Then the current URL should contain "/products/"
