@regression
Feature: Side navigation drawer (mobile)

  # Manual regression case 219 (added 2026-10-22). The Menu button and its
  # drawer only render at mobile width; on desktop the button is hidden.
  # Closing by clicking outside the drawer isn't covered: there's no generic
  # step for it, and Escape/Close exercise the same close handler.

  Background:
    Given I am on the "home" page
    And I resize the browser to a "mobile" viewport
    And I wait for the page to settle


  Scenario: Menu opens the drawer with its search box and categories
    When I click on the "Menu button" element
    Then the "navigation drawer" should be displayed
    And the "drawer search input" should have attribute "placeholder" with value "Search our products and pages..."
    And the "drawer Special Offers link" should be displayed


  Scenario: The drawer closes from its Close button
    When I click on the "Menu button" element
    Then the "navigation drawer" should be displayed
    When I click on the "drawer close" button
    Then the "navigation drawer" should not be displayed


  Scenario: The drawer closes with the Escape key
    When I click on the "Menu button" element
    Then the "navigation drawer" should be displayed
    When I press the Escape key
    Then the "navigation drawer" should not be displayed


  Scenario: Searching from the drawer opens the search results page
    When I click on the "Menu button" element
    And I fill in the "drawer search input" input field with "plywood"
    And I press Enter in the "drawer search input" input field
    Then I should eventually be redirected to the "search" page


  Scenario Outline: The drawer's "<link>" goes to the "<page>" page
    When I click on the "Menu button" element
    And I click on the "<link>" element, retrying until redirected to the "<page>" page
    Examples:
      | link                       | page           |
      | drawer Special Offers link | special-offers |
      | drawer Branches link       | branches       |


  # A category with sub-categories drills down inside the drawer instead of
  # navigating; its "View All" link is what opens the landing page.
  Scenario: A drawer category drills down and "View All" opens its landing page
    When I click on the "Menu button" element
    And I click on the "drawer Building Materials link" element
    Then the "drawer current category" should contain the text "Building Materials"
    And the "drawer back button" should be displayed
    When I click on the "drawer Building Materials View All" element, retrying until redirected to the "category-landing" page
