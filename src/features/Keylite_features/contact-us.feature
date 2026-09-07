@regression
Feature: Contact Us page

  # Real route is "/contact", not "/contact-us" - confirmed live 2026-09-06.
  # Like MIPA's contact-us.feature, this only checks the form renders rather
  # than submitting it - Keylite's fields have no data-testid (only raw
  # form-field name attributes), and submission behaviour/success state
  # wasn't confirmed live, so this stays a presence check for now.

  Scenario: Contact form fields are present
    Given I am on the "contact" page
    And I dismiss the newsletter popup if present
    Then the "First Name" should be displayed
    And the "Last Name" should be displayed
    And the "Contact Number" should be displayed
    And the "Email" should be displayed
    And the "Message" should be displayed
    And the "Submit Query" should be displayed
