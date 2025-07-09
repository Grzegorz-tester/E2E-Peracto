@regression
@carbon_regression
Feature: Articles Categories Page

  Scenario: Redirection to Article Categories
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Article Categories" tab
    Then I should be redirected to the "article-categories" page


  Scenario: Navigate to a specific Article Category

  Scenario: Delete an Article Category