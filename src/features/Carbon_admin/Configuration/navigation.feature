@carbon_regression
Feature: Navigation Page


  Scenario Outline: Navigate to a specific navigation group
    Given I am navigating the page as a "logged in" user
    When I click on the "Configuration" tab
    And I click on the "Navigation" tab
    Then I should be redirected to the "navigation" page
    When I click on the "<link>" link
    Then I should be redirected to the "<page>" page
    Examples:
      | link           | page           |
      | Orphaned pages | orphaned-pages |
      | Main menu      | main-menu      |
      | Footer         | footer         |
