@regression
@carbon_regression
Feature: Articles Page

  Scenario: Redirection to Articles
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Articles" tab
    Then I should be redirected to the "articles" page


  Scenario: Navigate to a specific article

  Scenario: Verify pagination on articles page

  Scenario: Delete an article