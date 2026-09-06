@smoke
@regression
Feature: Home Page

  # A Mailchimp signup popup loads asynchronously on a fresh page load and
  # blocks clicks on whatever's underneath it until dismissed - see the
  # Keylite-specific fallback added to "I dismiss the newsletter popup if
  # present" (newsletter-popup.ts), confirmed live 2026-09-06.

  Scenario: The main navigation renders every top-level section
    Given I am navigating the page as a "guest" user
    And I dismiss the newsletter popup if present
    Then the "Products nav link" should be displayed
    And the "Replace My Window nav link" should be displayed
    And the "Homeowners nav link" should be displayed
    And the "Professionals nav link" should be displayed
    And the "Support nav link" should be displayed
    And the "Find Installer nav link" should be displayed
