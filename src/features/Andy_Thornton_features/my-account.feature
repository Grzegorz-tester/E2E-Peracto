@Andy_Thornton_regression
Feature: Operations in the user's account

  # Every scenario below is blocked pending a real Andy Thornton test
  # account (see logging-in.feature and .env.example) and the account.json
  # tab selectors are a best-effort guess (Radix UI data-value, matching
  # this same site's checkout components) rather than confirmed live -
  # re-verify both once ANDY_THORNTON_LOGGED_IN_EMAIL/PASSWORD exist.

  Scenario: Check the presence of Dashboard elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Dashboard tab" tab
    Then I should be redirected to the "account" page

  Scenario: Check the presence of Profile elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Profile tab" tab
    Then I should be redirected to the "account-profile" page

  Scenario: Check the presence of Address book elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Address book tab" tab
    Then I should be redirected to the "account-address-book" page

  Scenario: Check the presence of Orders elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Orders tab" tab
    Then I should be redirected to the "account-orders" page

  Scenario: Check the presence of Moodboards elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Moodboards tab" tab
    Then I should be redirected to the "account-moodboards" page
