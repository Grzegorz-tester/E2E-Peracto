@Russells_regression
Feature: Checkout flow

  Background:
    Given I am navigating the page as a "logged in" user

  @smoke
  Scenario: Logged in user can proceed through checkout to billing
    Given I am on the "basket" page
    Then the "Basket title" should be displayed
    When I click on the "Checkout" button
    Then I should be redirected to the "checkout-sign-in" page
    When I click on the "Continue" button
    Then I should be redirected to the "checkout-delivery" page
    When I click on the "delivery continue" button
    And I click on the "delivery options continue" button
    Then I should be redirected to the "checkout-billing" page

  Scenario: Empty basket shows correct message
    Given I am on the "basket" page
    Then the "empty basket message" should be displayed
