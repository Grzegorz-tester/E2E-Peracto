@carbon_regression

Feature: All Forms Page


  Scenario: Redirection
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Forms" tab
    And I click on the "All Forms" tab
    Then I should be redirected to the "forms" page