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
