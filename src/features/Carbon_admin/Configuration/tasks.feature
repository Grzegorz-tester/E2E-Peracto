@carbon_regression
Feature: Tasks Page

  Scenario: Redirection
    Given I am navigating the page as a "logged in" user
    And I click on the "Configuration" tab
    When I click on the "Tasks" tab
    Then I should be redirected to the "tasks" page