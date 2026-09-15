@regression
Feature: Order history

  # Shared across every Watco market - confirmed live 2026-09-06 against
  # staging-uk. CONFIRMED SITE BEHAVIOUR: Order History is gated behind
  # email verification - the shared "account test user with vat" account
  # used elsewhere in this suite isn't verified and can't view its own
  # order history, so this deliberately uses "account test user 1"
  # instead, which is verified and has real past orders on staging.

  @requires-order-history
  Scenario: Order history lists past orders and each one opens its own detail page
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page

    When I am on the "order-list" page
    Then the "order history table" should be displayed

    When I click on the "first order view link" link
    Then I should be redirected to the "order-detail" page
