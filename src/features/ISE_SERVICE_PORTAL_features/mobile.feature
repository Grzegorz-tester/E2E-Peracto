@regression @creates-jobs
Feature: Mobile layout

  # The portal is mobile-first: engineers use their own phones (SoW project
  # overview; QA covers iOS 18 Safari and Android 15 Chrome). Runs the
  # engineer's core screens in a 390x844 viewport in Chromium. Real-device
  # and Safari checks stay manual.

  Background:
    Given I am navigating the page as a "engineer" user
    When I resize the browser to a "mobile" viewport

  @smoke
  Scenario: The engineer dashboard and menu work on a phone
    Then the "New job" should be visible
    And the "Search jobs" should be visible
    And the "Logout menu link" should not be visible
    When I click on the "Menu" element
    Then the "Logout menu link" should be visible

  Scenario: An engineer can start a job and reach the service date on a phone
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page
    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with "1 Velstar Test Street"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Next" button
    And I fill in the "PO number" input field with a unique code
    And I click on the "Installation option" element
    And I click on the "Inside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-replacement-product" page
    When I click on the "Standard 460 product" element
    And I click on the "Next" button
    Then I should be redirected to the "job-service-info" page
    When I click on the "Next" button
    Then I should be redirected to the "job-service-date" page
    When I fill in the "Service date" date input field with the date 7 days from today
    And I click on the "Book & Continue" button
    Then I should be redirected to the "job-new-setup" page
