@regression @creates-jobs
Feature: Installation job journey

  # ISE-SP.20 and SP.22 to SP.31 for the Installation journey, run as the
  # Service Engineer (assigned to "Test Company" on staging). Each scenario
  # creates its own job, as a "Velstar Test" customer with a VELSTAR-TEST- PO
  # number, so the jobs are easy to spot and ignore.
  #
  # Steps as built (CONFIRMED live, 2026-10-06): Replacement product,
  # Service info, Service date, New setup, Signature, Invoicing, Notes,
  # Complete. No Diagnosis or Current setup step for Installation, as the
  # SoW says.
  #
  # Completing a job sends the job-complete emails (approved for staging by
  # the user, 2026-10-07).
  #
  # Inside the radius, the status goes Assigned -> Booked as soon as Service
  # info is saved, which looks like the automatic order placement (SP.24).
  # Staging is expected to point at the ISE staging website; not verified.

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
    And I fill in the "Time" input field with "AM"
    And I click on the "Book & Continue" button
    Then I should be redirected to the "job-new-setup" page

  @smoke
  Scenario: An engineer can take an Installation job through to completion
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I upload the "velstar-test-job-photo.jpg" file to the "Below sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-signature" page
    When I click on the "Product guarantee" element
    And I click on the "Workmanship guarantee" element
    And I upload the "velstar-test-job-photo.jpg" file to the "Signature photo" input
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
    And I remember the current URL path as "complete step"
    # Server-side totals (SP.32): £85 call-out + 2 x £10 parts + £20 labour
    # = £125, plus 20% VAT.
    When I navigate directly to the remembered path "invoicing step"
    Then the "Parts total" should equal text "£20.00"
    And the "VAT amount" should equal text "£25.00"
    And the "Total amount" should equal text "£150.00"
    # SP.30: completing the job. Sends the job-complete emails (customer
    # address is a Velstar alias; the company and InSinkErator recipient
    # lists are empty on staging as of 2026-10-06).
    When I navigate directly to the remembered path "complete step"
    And I click on the "Submit" button
    Then the "completion message" should contain the text "has been completed."
    And the "completion message" should not contain the text "Aquatherm"
    When I click on the "Back to job" link
    Then I should be redirected to the "job-detail" page
    And the "job summary" should contain the text "Complete"
    And the "Continue job" should not be displayed

  Scenario: New setup rejects a job with only the above-sink photo
    # SP.27: both photos are a deliberate anti-fraud control.
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-new-setup" page
    And the "form error" should contain the text "below the sink"

  Scenario: Signature can't be submitted without both guarantee confirmations
    # CONFIRMED live (2026-10-06): currently FAILS. With only the product
    # guarantee ticked, Signature is accepted and the job moves on to
    # Invoicing. SP.28 requires both confirmations for Installation jobs.
    # The two checkboxes have no name attribute, so they aren't sent to the
    # server at all. Left red deliberately.
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I upload the "velstar-test-job-photo.jpg" file to the "Below sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-signature" page
    When I click on the "Product guarantee" element
    And I upload the "velstar-test-job-photo.jpg" file to the "Signature photo" input
    And I click on the "Next" button
    # Asserting "still on the signature page" alone passes falsely: it's
    # true the instant Next is clicked, before the submit navigates away.
    # A real rejection shows a validation error, so require that.
    Then the "form error" should be displayed
    And I should be redirected to the "job-signature" page

  Scenario: Continue job resumes at the next step that isn't done
    # CONFIRMED live (2026-10-06): currently FAILS. Once New setup is done,
    # "Continue job" still links to New setup, not Signature (seen twice,
    # including with Signature also done). SP.19 says Continue resumes at
    # the correct step. Left red deliberately.
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I upload the "velstar-test-job-photo.jpg" file to the "Below sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-signature" page
    When I click on the "Back" link
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-signature" page

  Scenario: Invoice VAT and total update as the engineer enters figures
    # CONFIRMED live (2026-10-06): currently FAILS. Parts, VAT and Total
    # stay at "-" while typing and only appear after saving (correctly,
    # £150.00 for these figures). SP.31 says they're calculated as the
    # engineer enters figures. Left red deliberately.
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I upload the "velstar-test-job-photo.jpg" file to the "Below sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-signature" page
    When I click on the "Product guarantee" element
    And I click on the "Workmanship guarantee" element
    And I upload the "velstar-test-job-photo.jpg" file to the "Signature photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-invoicing" page
    When I fill in the "Part quantity" input field with "2"
    And I fill in the "Part price" input field with "10.00"
    And I fill in the "Labour" input field with "20.00"
    Then the "Total amount" should equal text "£150.00"
