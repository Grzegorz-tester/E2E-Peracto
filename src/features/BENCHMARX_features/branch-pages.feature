@regression
Feature: Branch detail pages

  # BEN-379 (Next.js 15 upgrade) BR-04, BR-05, BR-07, BK-07 (branch entry
  # point). Built 2026-11-11 from a live inspection of staging.
  #
  # R2: on next-15 every branch page (e.g. /branches/leeds)
  # renders, then a server action POST fails and the page is replaced by the
  # Peracto 500 page; the console shows "An unexpected response was
  # received from the server". The HTTP status is still 200, so the
  # scenarios assert the content and the console, not just the status.
  #
  # Pre-existing on staging (not BEN-379): with location permission denied,
  # Get directions links to origin=undefined,undefined. Not asserted.

  # Console errors on this page are checked by global-layout.feature (GL-05).
  # BR-04: every branch page is the same template fed by the same data, so
  # one branch (Leeds, also used by BR-05 and BK-07) is enough. Was ten
  # branches across the regions until 2026-11-22.
  Scenario: A branch page shows its address, phone, hours, email and map
    Given I navigate directly to the path "/branches/leeds"
    And I wait for the page to settle
    Then the "branch heading" should be displayed
    And the "branch address" should be displayed
    And the "branch telephone" should be displayed
    And the "branch email" should contain the text "@"
    And the "branch Monday hours" should contain the text "Monday"
    And the "branch Sunday hours" should contain the text "Sunday"
    And the "branch map marker" should be displayed within "20" seconds
    And the "branch consultation button" should be displayed

  # BR-05
  Scenario: Enlarge map and Get directions open Google Maps in a new tab
    Given I navigate directly to the path "/branches/leeds"
    Then the "Enlarge map" should have attribute "href" containing "google.com/maps/search"
    And the "Enlarge map" should have attribute "target" with value "_blank"
    And the "Get directions" should have attribute "href" containing "google.com/maps/dir"
    And the "Get directions" should have attribute "target" with value "_blank"

  # BK-07: booking from a branch page.
  Scenario: The branch page's consultation button opens the booking form
    Given I navigate directly to the path "/branches/leeds"
    And I wait for the page to settle
    When I click on the "branch consultation button" button
    Then I should be redirected to the "book-a-consultation" page
    And the "step heading" should be displayed

  # BR-07: an unknown branch must be a branded 404, not a 500.
  Scenario: An unknown branch URL shows the branded 404 page with a 404 status
    Given I navigate directly to the path "/branches/does-not-exist"
    Then the "not found page" should be displayed
    And requesting the path "/branches/does-not-exist" should return status 404
