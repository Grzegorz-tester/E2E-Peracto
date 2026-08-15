@regression
Feature: Mid-session country switch

  # Ported from P3Playwright's insinkerator_eu/tests/navigation/
  # mid-session-country-switch.test.ts. Confirms a PDP's ecommerce gating
  # re-renders correctly live, without a page reload, when switching country
  # via the utility bar's picker AFTER the initial page load - as opposed to
  # the mandatory fresh-load "Choose your country" modal used everywhere
  # else in this project.

  @smoke
  Scenario: User can switch country via the utility bar and see PDP ecommerce gating update live
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Poland" button if present
    And I am on the "sink-flange-pdp" page

    Then the "where to buy button" should be displayed
    And the "Add to basket" should not be displayed
    And the "PDP price" should not be displayed

    When I click on the "utility bar country picker" button
    And I click on the "Select Portugal" button

    Then the "Add to basket" should be displayed
    And the "PDP price" should be displayed
    And the "where to buy button" should not be displayed
