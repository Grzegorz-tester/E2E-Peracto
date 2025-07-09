@regression
@carbon_regression
Feature: Templates Page

  Scenario: Redirection to Templates
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Templates" tab
    Then I should be redirected to the "templates" page