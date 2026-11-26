@regression @HIB-179
Feature: SAP and Recaptcha settings sections

  # Added 2026-11-19 for HIB-179: the PHP 8.5 upgrade rewrites the validator
  # constraints in HIB's own SapSection and RecaptchaSection configuration
  # classes (old array syntax -> named arguments). Those classes back the
  # Settings page's SAP and Recaptcha tabs (GET/PUT /configurations/sap and
  # /configurations/recaptcha). The shared admin suite never opens Settings
  # tabs, so nothing else exercises them.
  #
  # Confirmed live on staging 2026-11-19:
  # - SAP holds a single "Extra logs" switch (debug logging, off). The Save
  #   bar only appears once the form has a change, so the scenario ticks it,
  #   saves, unticks it and saves again, ending in the original state. Both
  #   saves show "Configuration successfully updated!".
  # - Recaptcha is READ-ONLY on HIB (readOnly: true, inputs disabled):
  #   enabled, endpoints /users, /users/reset-password, /form-submissions.
  #   It can only be checked as loading, not saved.
  # - Each tab has its own Save button; only the selected panel's is
  #   visible, hence the panel-scoped "Save settings" mapping.

  Background:
    Given I am navigating the page as a "admin" user
    And I am on the "settings" page
    And the "page heading" should contain the text "Settings"


  @mutates-admin-data
  Scenario: The SAP settings section saves (Extra logs ticked, then restored)
    When I click precisely on the "SAP tab" element
    Then the "selected settings panel" should contain the text "Extra logs"
    And the "Extra logs input" radio button should not be checked
    When I click precisely on the "Extra logs checkbox" element
    And I click precisely on the "Save settings" button
    Then the "success toast" should contain the text "Configuration successfully updated"
    And the "Extra logs input" radio button should be checked
    When I click precisely on the "Extra logs checkbox" element
    And I click precisely on the "Save settings" button
    Then the "success toast" should be displayed
    And the "Extra logs input" radio button should not be checked


  Scenario: The Recaptcha settings section loads with its protected endpoints
    When I click precisely on the "Recaptcha tab" element
    Then the "selected settings panel" should contain the text "Enable validation"
    And the "selected settings panel" should contain the text "/users/reset-password"
    And the "selected settings panel" should contain the text "/form-submissions"
    And the "Enable validation input" radio button should be checked
