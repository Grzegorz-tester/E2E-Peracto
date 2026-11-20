@regression
Feature: Quote Builder access by customer group

  # Smoke cases 43 and 50 (AN-2026-11-19.json), added 2026-11-19.
  # Confirmed live on staging 2026-11-19 via the admin API: Quote Builder
  # access comes from the "Sales Team" customer group (access_all_quotes);
  # the plain "User" group gets Moodboards. "non admin" is in "User".
  #
  # Case 50 (a Quote-Builder-only user can't reach Moodboards) is NOT
  # automated yet: the only Sales Team test account ("logged in") is also
  # ROLE_ADMIN, and it can open /account/moodboards directly, so it can't
  # show whether the restriction holds for a plain Sales Team user. Needs a
  # dedicated Sales-Team-only test account (ANDY_THORNTON_QUOTE_BUILDER_*).

  # Case 43: a Moodboard-only user (the "User" customer group) has no Quotes.
  Scenario: A Moodboard-only user has no Quotes option and is turned away from the Quotes page
    Given I am navigating the page as a "non admin" user
    When I am on the "account" page
    Then the "account nav Moodboards link" should be displayed
    And the "account nav Quotes link" should not be displayed
    When I navigate directly to the path "/account/quotes"
    Then I should eventually be redirected to the "account" page
