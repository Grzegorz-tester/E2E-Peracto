@regression
Feature: Footer and newsletter sign-up

  # Built 2026-09-30 from a live inspection of staging. Every internal
  # footer link is also checked by health-check.feature.
  #
  # The newsletter form is never submitted with a real address (it would
  # subscribe it to Andy Thornton's mailing list); only its own browser
  # validation of a malformed address is checked, which sends nothing.

  Background:
    Given I am on the "home" page
    And I click on the "Allow all cookies" button if present


  Scenario: The footer shows its links, social icons and company details
    Then the "footer" should be displayed
    And the "footer internal links" should be displayed
    And the "Facebook footer icon" should be displayed
    And the "Instagram footer icon" should be displayed
    And the "LinkedIn footer icon" should be displayed
    And the "footer Twitter icon" should be displayed
    And the "footer Pinterest icon" should be displayed
    And the "footer TikTok icon" should be displayed
    And the "footer company info" should be displayed
    And the "footer sitemap link" should be displayed


  Scenario: The footer Sitemap link opens the sitemap
    When I click on the "footer sitemap link" link
    Then I should eventually be redirected to the "sitemap" page
    And a heading with the text "Sitemap" should be displayed


  Scenario: The newsletter form rejects a malformed email address without submitting
    Then the "newsletter form" should be displayed
    And the "newsletter privacy policy link" should be displayed
    When I fill in the "newsletter email input" input field with "not-an-email"
    And I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as invalid
