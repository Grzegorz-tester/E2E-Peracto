@regression @creates-jobs
Feature: Warranty job journey

  # ISE-SP.20 to SP.32 for the Warranty Service journey, run as the Service
  # Engineer (Test Company). Each scenario creates its own "Velstar Test"
  # job. Steps as built (CONFIRMED live, 2026-10-06): Diagnosis,
  # Replacement product, Service info, Service date, Current setup, New
  # setup, Signature, Invoicing, Notes, Complete.
  #
  # Inside the radius, the status goes Assigned -> Awaiting part once
  # Service info is saved (Installation goes to Booked instead), which looks
  # like the warranty replacement order being placed (SP.24).
  #
  # As in the Installation journey, the final Complete Job "Submit" is never
  # clicked: it sends real job-complete emails.
  #
  # CONFIRMED live, open question (not asserted): Diagnosis accepts an
  # entirely empty form (no complaint code, no fault code) and marks the
  # step complete. The SoW doesn't say these are required, but the
  # Aquatherm export relies on them.
  #
  # CONFIRMED live, differs from SoW: step 1 has a single installed address
  # for Warranty too. SP.20 says Warranty takes billing plus delivery
  # addresses, with an override.

  Background:
    Given I am navigating the page as a "engineer" user
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page
    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I fill in the "Phone" input field with "07000000000"
    And I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with "1 Velstar Test Street"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Next" button
    And I fill in the "PO number" input field with a unique code
    And I click on the "Warranty Service option" element
    And I click on the "Inside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-diagnosis" page
    When I select the "ELEC-04 - Trips circuit breaker" option from the "Complaint code" dropdown
    And I select the "F-134 - Wiring fault" option from the "Fault code" dropdown
    And I fill in the "Existing serial number" input field with "VELSTAR-TEST-OLD-SN"
    And I fill in the "Original installation date" input field with "2024-01-15"
    And I fill in the "Water pressure" input field with "3 bar"
    And I click on the "Next" button
    Then I should be redirected to the "job-replacement-product" page
    When I click on the "Standard 460 product" element
    And I click on the "Next" button
    Then I should be redirected to the "job-service-info" page
    When I click on the "Next" button
    Then I should be redirected to the "job-service-date" page
    And the "job summary" should contain the text "Awaiting part"
    When I fill in the "Service date" date input field with the date 7 days from today
    And I fill in the "Time" input field with "AM"
    And I click on the "Book & Continue" button
    Then I should be redirected to the "job-current-setup" page

  @smoke
  Scenario: An engineer can take a Warranty job through to the Complete screen
    When I upload the "velstar-test-job-photo.jpg" file to the "On-arrival photo" input
    And I fill in the "Confirm serial number" input field with "VELSTAR-TEST-OLD-SN"
    And I fill in the "Water pressure" input field with "3 bar"
    And I click on the "Next" button
    Then I should be redirected to the "job-new-setup" page
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I upload the "velstar-test-job-photo.jpg" file to the "Below sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-signature" page
    # SP.28: the guarantee confirmations are Installation-only.
    And the "Product guarantee checkbox" should not be displayed
    When I upload the "velstar-test-job-photo.jpg" file to the "Signature photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-invoicing" page
    And I remember the current URL path as "invoicing step"
    And the "Standard call-out amount" should equal text "£85.00"
    When I fill in the "Part quantity" input field with "2"
    And I fill in the "Part number" input field with "VELSTAR-TEST-PART"
    And I fill in the "Part description" input field with "Velstar Test part"
    And I fill in the "Part price" input field with "10.00"
    And I fill in the "Labour" input field with "20.00"
    And I click on the "Next" button
    Then I should be redirected to the "job-notes" page
    When I fill in the "Engineer comments" input field with "Velstar Test - automated E2E run, please ignore."
    And I click on the "Next" button
    Then I should be redirected to the "job-complete" page
    And the "completion confirmation" should be displayed
    And the "Submit" should be displayed
    When I navigate directly to the remembered path "invoicing step"
    Then the "Parts total" should equal text "£20.00"
    And the "VAT amount" should equal text "£25.00"
    And the "Total amount" should equal text "£150.00"

  Scenario: Current setup requires the on-arrival photo
    # SP.26: photo of the product before removal.
    When I fill in the "Confirm serial number" input field with "VELSTAR-TEST-OLD-SN"
    And I click on the "Next" button
    Then the "form error" should contain the text "before starting work"
    And I should be redirected to the "job-current-setup" page
