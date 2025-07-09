@carbon_regression
Feature: Countries Page

  Background:
    Given I am navigating the page as a "logged in" user
    When I click on the "Configuration" tab
    And I click on the "Countries" tab
    Then I should be redirected to the "countries" page


  Scenario Outline: Check the existence of a country
    And the "1st" "country" should contain the text "<country name>"
    Examples:
      | country name   |
      | United Kingdom |

  Scenario Outline: Check the billing and delivery boxes are checked
    Examples: