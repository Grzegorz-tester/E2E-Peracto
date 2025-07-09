@regression
@carbon_regression
Feature: Element Areas Page

  Scenario: Redirection to Element Areas
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Element Areas" tab
    Then I should be redirected to the "element-areas" page