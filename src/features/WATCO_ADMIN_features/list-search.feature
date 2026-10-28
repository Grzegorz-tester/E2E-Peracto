@regression
Feature: Searching admin lists

  # Read-only DataTables searches that double as checks on data other
  # suites depend on.

  Scenario: The storefront's promo-code fixture is still present and findable
    # Backs WATCO_features/basket-promo-code.feature (promotion 647, created
    # 2026-10-24, "do not delete"). If this fails, that fixture is gone.
    Given I am navigating the page as a "admin" user
    When I am on the "promotions" page
    And I fill in the "list search" input field with "VELSTARTEST1"
    Then the "first row" should contain the text "Velstar Test Automation - VELSTARTEST1"
    And the "list info" should contain the text "of 1 entries"

  Scenario: Searching users finds the admin's own account
    Given I am navigating the page as a "admin" user
    When I am on the "users" page
    And I fill in the "list search" input field with "watcouk_automation"
    Then the "first row" should contain the "admin" user's email

  Scenario: Orders placed by the storefront test suite reach the admin
    # The storefront suites place real staging orders as "Velstar Test"
    # (e.g. guest-checkout-card-payment.feature), so this proves storefront
    # orders arrive in the admin. Confirmed live 2026-10-24 (WUK129648).
    Given I am navigating the page as a "admin" user
    When I am on the "orders" page
    And I fill in the "list search" input field with "Velstar Test"
    Then the "first row" should contain the text "Velstar Test"

  Scenario: A search with no matches shows the empty state
    Given I am navigating the page as a "admin" user
    When I am on the "promotions" page
    And I fill in the "list search" input field with "VELSTARNOSUCHPROMOTION"
    Then the "list rows" should not be displayed
    And the "list info" should contain the text "0 entries"
