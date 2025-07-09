@regression
@carbon_regression
Feature: Locations Page

  Scenario: Redirection to Locations
    Given I am navigating the page as a "logged in" user
    When I click on the "Locations" link
    Then I should be redirected to the "locations" page

#  Then

  Scenario: Navigate to a specific location

  Scenario: Delete a location