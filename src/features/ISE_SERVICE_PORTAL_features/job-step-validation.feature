@regression @creates-jobs
Feature: Job step validation

  # Required fields on the job steps, run as the Service Engineer. The
  # anti-fraud photo rules (SP.26/27) and the Installation guarantees
  # (SP.28) are covered in the journey features.
  #
  # CONFIRMED live (2026-10-06): step 1 needs the customer's first and last
  # name, and won't move on without an email either (or a phone), although
  # only the names are marked required. Diagnosis accepts an entirely empty
  # form (open question, not asserted).

  Background:
    Given I am navigating the page as a "engineer" user
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page

  Scenario: A job can't move past customer details without a first name
    When I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I click on the "Next" button
    Then the "First name input" input should be rejected as empty
    And the "Step 2 heading" should not be visible

  Scenario: Warranty Service is pre-selected as the Service Type
    # CONFIRMED live (2026-10-07): the Service Type radios default to
    # Warranty Service, so a job can't be created without one - an engineer
    # who doesn't switch it files an Installation as a Warranty job.
    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with "1 Velstar Test Street"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Next" button
    Then the "Step 2 heading" should be visible
    And the "Warranty Service radio" radio button should be checked

  Scenario: Booking a service date is required
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
    When I click on the "Book & Continue" button
    Then the "Service date" input should be rejected as empty
    And I should be redirected to the "job-service-date" page
