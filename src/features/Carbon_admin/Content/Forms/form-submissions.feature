@carbon_regression

Feature: Form Submissions Page


  Scenario: Redirection
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Forms" tab
    And I click on the "Form Submissions" tab
    Then I should be redirected to the "form-submissions" page