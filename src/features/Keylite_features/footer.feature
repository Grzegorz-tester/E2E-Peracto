@regression
Feature: Footer

  # Confirmed live 2026-09-06: Keylite's footer has no single "all nav
  # links" grouping like MIPA's - social icons and the bottom
  # company-info/sitemap strip are the confirmed reusable selectors.

  Scenario: Footer social media icons are present and resolve
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    Then the "footer Facebook icon" should be displayed
    And the "footer Instagram icon" should be displayed
    And the "footer LinkedIn icon" should be displayed
    And the "footer YouTube icon" should be displayed

  Scenario: Company info and sitemap link are present in the footer
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    Then the "footer company info" should be displayed
    And the "footer copyright" should be displayed
    And the "footer sitemap link" should be displayed
