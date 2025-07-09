@carbon_regression

Feature: Shipping Services Page


  Scenario: Redirection
    Given I am navigating the page as a "logged in" user
    And I click on the "Configuration" tab
    When I click on the "Shipping Services" tab
    Then I should be redirected to the "shipping-services" page