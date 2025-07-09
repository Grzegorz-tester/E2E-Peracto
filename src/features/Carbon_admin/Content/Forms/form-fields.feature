@carbon_regression

Feature: Form Fields Page


  Scenario: Redirection
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Forms" tab
    And I click on the "Form Fields" tab
    Then I should be redirected to the "form-fields" page