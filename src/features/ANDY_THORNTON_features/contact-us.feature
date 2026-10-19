@regression
Feature: Contact Us

  # Built 2026-09-30 from a live inspection of staging. The enquiry form
  # emails real Andy Thornton staff, so it is NEVER submitted with valid
  # details on any environment. Its required fields use browser validation,
  # so an empty submit is blocked before anything is sent (confirmed live).

  Background:
    Given I am on the "contact-us" page
    And I click on the "Allow all cookies" button if present


  Scenario: The Contact Us page shows the enquiry form and location map
    Then a heading with the text "How can we help?" should be displayed
    And the "First name" should be displayed
    And the "Last name" should be displayed
    And the "Email address" should be displayed
    And the "Message" should be displayed
    And the "Send Enquiry" should be displayed
    And the "location map" should be displayed


  Scenario: Sending an empty enquiry is blocked by the required fields
    When I click on the "Send Enquiry" button
    Then the "First name" input should be rejected as empty
    And the "Last name" input should be rejected as empty
    And the "Email address" input should be rejected as empty
    And the "Message" input should be rejected as empty
    And I should be redirected to the "contact-us" page


  Scenario: A malformed email address is rejected
    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email address" input field with "not-an-email"
    And I fill in the "Message" input field with "Velstar Test - validation check, not sent"
    And I click on the "Send Enquiry" button
    Then the "Email address" input should be rejected as invalid
    And I should be redirected to the "contact-us" page
