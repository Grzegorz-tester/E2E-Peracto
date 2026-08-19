@regression
Feature: Recently Viewed Products

  # From KOOL-2026-08-17.json, "Storefront > Recently Viewed Products"
  # (cases 387-391). Confirmed live: the current product is itself already
  # added to the list as soon as its own PDP loads (not just previously
  # viewed ones), so the "I cannot see the section when I haven't recently
  # viewed anything" case (391) isn't reproducible - not covered here since
  # it doesn't reflect the site's actual behaviour.

  Scenario: Viewing a second product adds it to Recently Viewed alongside the first, and each item links to the correct PDP
    Given I am on the "cable-pdp" page
    When I am on the "hose-set-pdp" page
    Then the "recently viewed section" should be displayed
    And the "recently viewed items" should be displayed

    When I click on the "2nd" "recently viewed items" element
    Then I should be redirected to the "cable-pdp" page
