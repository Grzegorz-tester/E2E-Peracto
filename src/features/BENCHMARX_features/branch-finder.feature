@smoke @regression
Feature: Branch finder

  # Qase BEN-109. Built 2026-10-24 from a live inspection of staging. The
  # search box is Google Places autocomplete, but pressing Enter on a typed
  # town works without picking a suggestion. Results are links to each
  # branch page, nearest first, with distance, address and phone number.
  #
  # CONFIRMED SITE DEFECT (2026-10-24): searching before the Google Maps
  # script has loaded (within ~1s of landing) crashes the whole page into a
  # "500 Application Error" (TypeError: window.google.maps.Geocoder is not a
  # constructor). Waiting ~6s first works, so the scenario settles before
  # searching. Worth raising: a slow connection could hit it for real.

  Scenario: Searching a town lists the nearest branches with their details
    Given I am on the "branches" page
    And I wait for the page to settle
    When I fill in the "branch search input" input field with "Leeds"
    And I press Enter in the "branch search input" input field
    Then the "first branch result" should contain the text "Leeds"
    And the "first branch result" should contain the text "miles"
    And the "first branch result" should contain the text "LS11 0EY"
    And the "first branch result" should contain the text "Tel:"
    When I click on the "first branch result" link
    Then I should be redirected to the "branch" page
    And the "page heading" should contain the text "Leeds"

  Scenario: The full branch list links to every branch page
    Given I am on the "branches" page
    Then the "all branches list" should be displayed
    And the first 10 "all branches links" links should resolve without an error

  # ---- BEN-379 (Next.js 15 upgrade) additions, 2026-11-11 ----
  # R3: on next-15 /branches never renders the branch finder (endless
  # spinner, no map, no list); staging shows a Google map with clustered
  # markers. Branch detail pages are in branch-pages.feature.

  # BR-01
  Scenario: The branch finder shows a map with clustered branch markers
    Given I am on the "branches" page
    Then the "branch finder" should be displayed within "20" seconds
    And the "branch finder map" should be displayed within "20" seconds
    And the "branch map markers" should be displayed within "20" seconds

  # BR-02: a postcode works like a town.
  Scenario: Searching a postcode lists the nearest branch first
    Given I am on the "branches" page
    And I wait for the page to settle
    When I fill in the "branch search input" input field with "LS11 0EY"
    And I press Enter in the "branch search input" input field
    Then the "first branch result" should contain the text "Leeds"
    And the "first branch result" should contain the text "miles"

  # BR-03
  Scenario: View all branches jumps to the A to Z list, which filters by letter
    Given I am on the "branches" page
    And I wait for the page to settle
    When I click on the "View all branches" link
    Then the "all branches list" should be displayed
    And the "branch list links" should be displayed
    When I click on the "letter filter B" button
    Then the "branch list links" should all contain the text "B"
    When I click on the "first branch list link" link
    Then I should be redirected to the "branch" page
    And the "branch heading" should be displayed
