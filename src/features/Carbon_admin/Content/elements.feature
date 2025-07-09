@regression
@carbon_regression
Feature: Elements Page

  Scenario: Redirection to Elements
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Elements" tab
    Then I should be redirected to the "elements" page
