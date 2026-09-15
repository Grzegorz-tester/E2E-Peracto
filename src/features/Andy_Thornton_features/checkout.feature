@regression
Feature: Checkout sign-in step

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): see
  # PDP.feature - an undismissed Cookiebot banner intercepts "Add to
  # basket" on a fresh consent-less context, leaving the basket empty
  # (so "Checkout" never appears). Also see PDP.feature's second note:
  # navigating to "basket" too fast after clicking can race the
  # add-to-basket request itself - "I wait for the page to settle" first.

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): clicking
  # "Checkout" doesn't redirect to /checkout instantly - a scenario that
  # acts immediately afterwards without waiting for it (e.g. clicking
  # "Guest checkout radio" straight away) can still be sitting on /basket,
  # where that element isn't mapped at all ("no selector resolved").
  # Confirming the redirect in Background, once, covers every scenario.
  Background:
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    When I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    And I click on the "Checkout" button
    Then I should be redirected to the "checkout" page

  Scenario: Verify checkout sign-in step elements
    Then the "checkout total" should be displayed
    And the "Existing customer radio" should be displayed
    And the "Guest checkout radio" should be displayed

  Scenario: Verify choosing Guest checkout reveals the guest email field
    When I click on the "Guest checkout radio" button
    Then the "Guest email" should be displayed
