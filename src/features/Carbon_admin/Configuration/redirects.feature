@carbon_regression
Feature: Redirects Page


  Scenario: Redirection
    Given I am navigating the page as a "logged in" user
    And I click on the "Configuration" tab
    When I click on the "Redirects" tab
    Then I should be redirected to the "redirects" page