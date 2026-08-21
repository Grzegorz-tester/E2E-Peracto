@regression
Feature: Contact Us page

  # Covers the manual test plan's "Contact Us Page" suite (6 cases). The
  # form is a generic Peracto CMS form-builder block (its fields have no
  # data-testid, only stable placeholder text/id attributes), confirmed
  # live (2026-08-21): a valid submission navigates to a dedicated
  # "contact-success" page; an empty required-field submission is blocked
  # by native HTML5 validation, same pattern as the register form. There is
  # no distinct "Find Us" map/section on this page - the closest live
  # equivalent is the "Branch Finder" callout link the page shows instead,
  # covered below rather than a section that doesn't exist.

  Background:
    Given I am on the "contact" page

  Scenario: Contact form and page content are present
    Then the "Contact subject dropdown" should be displayed
    And the "Contact full name" should be displayed
    And the "Contact email" should be displayed
    And the "Contact message" should be displayed
    And the "Contact submit button" should be displayed
    And the "Contact Us email" should be displayed
    And the "contact phone number" should be displayed
    And the "Branch Finder link" should be displayed

  Scenario: Submitting the form with valid data succeeds
    When I fill in the "Contact full name" input field with "Velstar Test"
    And I fill in the "Contact email" input field with a unique guest email
    And I fill in the "Contact message" input field with "Velstar QA test message - please ignore."
    And I click on the "Contact submit button" button
    Then I should be redirected to the "contact-success" page

  Scenario: Submitting the form with an invalid email is rejected
    When I fill in the "Contact email" input field with "not-an-email"
    Then the "Contact email" input should be rejected as invalid

  Scenario: Submitting the form with empty required fields is rejected
    When I click on the "Contact submit button" button
    Then the "Contact full name" input should be rejected as empty
