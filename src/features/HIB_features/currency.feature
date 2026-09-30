@regression
Feature: Currency switching
  - GBP is the site's default currency; EUR is the only other option in the
    header currency picker.
  - PLP (category grid) pages currently show no price at all on this site
    (name/image/variant-count only), so PLP is intentionally out of scope
    here - only the PDP, where price is actually shown.
  - The picker is only offered to guests; logged-in portal users never see
    it (confirmed correct behaviour, 2026-09-29).


  Scenario: Currency toggle is visible on the site
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    Then the "currency picker" should be displayed


  Scenario: Switching currency updates the PDP price and reverts back
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    Then the "product price" should contain the text "£"
    When I switch the currency to "EUR"
    Then the "product price" should contain the text "€"
    When I switch the currency to "GBP"
    Then the "product price" should contain the text "£"


  # 2026-09-29: logged-in (portal) users get no currency picker at all - on
  # /, /account and PDPs alike. Confirmed with the user as correct behaviour,
  # not a bug. The basket (place-order) is portal-only, so basket currency
  # switching can't be tested; guard the intended behaviour instead.
  Scenario: Currency picker is hidden for logged-in users
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "home" page
    Then the "Search products" should be displayed
    And the "currency picker" should not appear within "5" seconds
