@regression
Feature: Find an Installer or Stockist

  # CONFIRMED live 2026-09-23: /branches ("Find Installer" in the header)
  # searches via a Google Places autocomplete input - typing a postcode and
  # pressing Enter is enough, no suggestion needs picking. Results render
  # inside [data-testid='branch-finder'] (NOT the similarly named
  # 'all-branches', which only holds the tabs/filters), with no per-result
  # testids, each as
  # "<NAME> | (<n> miles) | <address> | Tel: <number>" - so the assertions
  # below check that shape rather than any specific (real, changeable)
  # installer.

  Background:
    Given I am navigating the page as a "guest" user
    And I am on the "branches" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle

  Scenario: Searching by postcode lists nearby installers with distance and phone number
    Then the "page heading" should contain the text "Find an Installer or Stockist"
    When I fill in the "branch search" input field with "SW1A 2AA"
    And I press Enter in the "branch search" input field
    And I wait for the page to settle
    Then the "branch results" should contain the text "miles"
    And the "branch results" should contain the text "Tel:"

  Scenario: Switching to Stockists and searching lists nearby stockists
    When I click on the "1st" "Stockist tab" element via JavaScript
    And I fill in the "branch search" input field with "SW1A 2AA"
    And I press Enter in the "branch search" input field
    And I wait for the page to settle
    Then the "branch results" should contain the text "miles"
