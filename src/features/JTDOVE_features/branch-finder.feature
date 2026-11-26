@regression
Feature: Branch finder

  # New coverage (2026-10-05). /branches lists all 21 branches (20 "JT Dove
  # <town>" plus Nordstrom Timber (Sunderland)), with an A-Z letter filter and
  # a postcode/town search box.

  @smoke
  Scenario: Branch finder lists every branch
    Given I am on the "branches" page
    And I wait for the page to settle
    Then the "branch finder" should be displayed
    And I should see "21" "branch cards" displayed


  @smoke
  Scenario: A branch page shows its opening hours and contact details
    Given I am on the "branches" page
    And I wait for the page to settle
    When I click on the "Hexham branch link" element, retrying until redirected to the "branch-hexham" page
    Then the "branch heading" should contain the text "JT Dove Hexham"
    And the "branch monday hours" should contain the text "7:30 am - 5:00 pm"
    And the "branch sunday hours" should contain the text "Closed"
    And the "branch address" should contain the text "NE46 4DQ"
    And the "branch telephone" should contain the text "01434 600062"
    And the "branch email" should contain the text "hexham@jtdove.co.uk"
    And the "Get directions" should be displayed
    And the "other branches nearby" should be displayed


  # The letter filter keys on each branch's FULL name, so all 20 "JT Dove
  # <town>" branches sit under "J", Nordstrom Timber under "N", and every
  # other letter is disabled ("H" can't find Hexham). Reported as a defect
  # 2026-10-05, but this is the CLIENT-APPROVED behaviour (confirmed by the
  # user 2026-11-23) until it's reviewed. If the filter is changed to use the
  # town name, rewrite this to click "H" and expect Hawick, Hetton, Hexham.
  Scenario: The A-Z filter groups branches by the first letter of their full name
    Given I am on the "branches" page
    And I wait for the page to settle
    Then the "J filter" should be enabled
    And the "N filter" should be enabled
    And the "H filter" should not be enabled
    When I click on the "N filter" element
    Then I should see "1" "branch cards" displayed
    And the "branch cards" should all contain the text "Nordstrom Timber"
    When I click on the "J filter" element
    Then I should see "20" "branch cards" displayed
    And the "branch cards" should all contain the text "JT Dove"


  # Manual regression case 109 (added 2026-10-22).
  Scenario: "View all branches" scrolls to the full branch list
    Given I am on the "branches" page
    And I wait for the page to settle
    When I click on the "View all branches" link
    Then the "all branches section" should be scrolled into view


  # KNOWN SITE ISSUE (confirmed live 2026-10-05): the search box never
  # suggests anything - the page logs "[react-google-places-autocomplete]:
  # Google script not loaded", the same Maps-script failure seen on KOOL's
  # release branch finder. Expected to stay red until the Google Maps script
  # loads on staging.
  @smoke
  Scenario: Searching for a town suggests matching places
    Given I am on the "branches" page
    And I wait for the page to settle
    When I fill in the "branch search input" input field with "Hexham"
    Then the "address autocomplete options" should be displayed within "10" seconds
