@regression
Feature: Checkout sign-in step

  Background:
    Given I am on the "pdp" page
    When I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout" button

  Scenario: Verify checkout sign-in step elements
    Then I should be redirected to the "checkout" page
    And the "checkout total" should be displayed
    And the "Existing customer radio" should be displayed
    And the "Guest checkout radio" should be displayed

  Scenario: Verify choosing Guest checkout reveals the guest email field
    When I click on the "Guest checkout radio" button
    Then the "Guest email" should be displayed
