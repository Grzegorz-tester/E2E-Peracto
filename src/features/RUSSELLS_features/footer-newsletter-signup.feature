@regression
Feature: Footer newsletter sign-up

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: Footer newsletter form is visible
    Then the "Newsletter form" should be displayed
    And the "Newsletter title" should be displayed
    And the "Newsletter email" should be displayed
    And the "Newsletter submit" should be displayed

  Scenario: Submitting an empty email is blocked by validation
    When I click on the "Newsletter submit" button
    Then the "Newsletter email" input should be rejected as empty
    And the "Newsletter alert" should not be displayed

  Scenario: Submitting a malformed email is blocked by validation
    When I fill in the "Newsletter email" input field with "not-an-email"
    And I click on the "Newsletter submit" button
    Then the "Newsletter email" input should be rejected as invalid
    And the "Newsletter alert" should not be displayed

  Scenario: Submitting a well-formed email shows a success confirmation
    When I fill in the "Newsletter email" input field with a unique guest email
    And I click on the "Newsletter submit" button
    Then the "Newsletter alert" should contain the text "Thank you for subscribing"
