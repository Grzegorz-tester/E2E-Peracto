@regression
Feature: Branch finder

  # New coverage (2026-10-05). /branches lists all 21 branches (20 "JT Dove
  # <town>" plus Nordstrom Timber (Sunderland)), with an A-Z letter filter and
  # a postcode/town search box.

  Scenario: Branch finder lists every branch
    Given I am on the "branches" page
    And I wait for the page to settle
    Then the "branch finder" should be displayed
    And I should see "21" "branch cards" displayed


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


  # KNOWN SITE ISSUE (confirmed live 2026-10-05): the letter filter keys on
  # each branch's FULL name, so all 20 "JT Dove <town>" branches sit under
  # "J" and every other letter except "N" (Nordstrom Timber) is disabled -
  # "H" can't be used to find Hexham, Hawick or Hetton. Expected to stay red
  # until the filter uses the town name.
  Scenario: Filtering by a town's first letter shows that town's branches
    Given I am on the "branches" page
    And I wait for the page to settle
    When I click on the "H filter" element
    Then the "branch cards" should all contain the text "JT Dove H"


  # KNOWN SITE ISSUE (confirmed live 2026-10-05): the search box never
  # suggests anything - the page logs "[react-google-places-autocomplete]:
  # Google script not loaded", the same Maps-script failure seen on KOOL's
  # release branch finder. Expected to stay red until the Google Maps script
  # loads on staging.
  Scenario: Searching for a town suggests matching places
    Given I am on the "branches" page
    And I wait for the page to settle
    When I fill in the "branch search input" input field with "Hexham"
    Then the "address autocomplete options" should be displayed within "10" seconds
