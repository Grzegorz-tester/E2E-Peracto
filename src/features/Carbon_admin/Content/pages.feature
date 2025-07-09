@regression
@carbon_regression
Feature: Pages Page

  Scenario: Redirection to Pages
    Given I am navigating the page as a "logged in" user
    When I click on the "Content" tab
    And I click on the "Pages" tab
    Then I should be redirected to the "pages" page


  Scenario: Navigate to a specific page

  Scenario: Verify pagination on pages page

  Scenario: Delete a page