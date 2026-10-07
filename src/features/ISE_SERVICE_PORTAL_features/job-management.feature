@regression @creates-jobs
Feature: Job management by Owner and Admin

  # ISE-SP.19 / SP.33 from the office side: an Owner or Admin can raise a
  # job for any company, assign or change its engineer, and edit everything
  # on it from "Edit job" (status, customer, installation/billing/delivery
  # addresses, diagnosis, products, service info, date, invoice, notes).
  #
  # CONFIRMED live (2026-10-07): a job raised without an engineer shows
  # "This job has no engineer yet, so it can't be ordered." until one is
  # assigned. "Change engineer" and "Edit job" are still offered on a
  # completed job (open question - completed jobs feed the Aquatherm
  # export).

  Background:
    Given I am navigating the page as a "owner" user
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page
    When I select the "Test Company" option from the "Service company" dropdown
    And I fill in the "First name" input field with "Velstar"
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
    And I remember the current URL path as "job page"

  @smoke
  Scenario: A job raised by the Owner needs an engineer before it can be ordered
    Then the "no engineer warning" should contain the text "This job has no engineer yet, so it can't be ordered."
    When I click precisely on the "Assign engineer" link
    Then I should be redirected to the "job-assign" page
    When I select the "Grzegorz Hajduk" option from the "Assigned engineer" dropdown
    And I click on the "Save" button
    Then I should eventually be redirected to the "job-detail" page
    And the "engineer name" should contain the text "Grzegorz Hajduk"
    And the "no engineer warning" should not be displayed
    # The assigned engineer now has it on their dashboard.
    When I remember the part of the "job heading" text matching the pattern "(JOB-[0-9A-F]+)" as "job reference"
    And I navigate directly to the path "/logout"
    And I am navigating the page as a "engineer" user
    And I fill in the "Search jobs" input field with the remembered "job reference"
    And I press Enter in the "Search jobs" input field
    Then the "first job card reference" should contain the remembered "job reference"

  Scenario: A job with no engineer is shown as New, not Assigned
    # LIKELY DEFECT (CONFIRMED live, 2026-10-07): a job raised with no
    # engineer gets status "Assigned", so the dashboard's "New" filter is
    # always empty. The SoW doesn't define the statuses - confirm with the
    # team. Left red.
    Then the "no engineer warning" should be displayed
    And the "job summary" should contain the text "New"

  Scenario: The Owner changes a job's engineer
    When I click precisely on the "Assign engineer" link
    Then I should be redirected to the "job-assign" page
    When I select the "Grzegorz Hajduk" option from the "Assigned engineer" dropdown
    And I click on the "Save" button
    Then I should eventually be redirected to the "job-detail" page
    When I click precisely on the "Change engineer" link
    Then I should be redirected to the "job-assign" page
    When I select the "Test Engineer" option from the "Assigned engineer" dropdown
    And I click on the "Save" button
    Then I should eventually be redirected to the "job-detail" page
    And the "engineer name" should contain the text "Test Engineer"

  Scenario: The Owner edits a job's customer phone and adds billing and delivery addresses
    When I click precisely on the "Edit job" link
    Then I should be redirected to the "job-edit" page
    When I fill in the "Phone" input field with "07111111111"
    And I click on the "Billing Enter manually" button
    And I fill in the "Billing address line 1" input field with "2 Velstar Billing Road"
    And I fill in the "Billing town" input field with "York"
    And I fill in the "Billing postcode" input field with "YO1 1AA"
    And I click on the "Delivery Enter manually" button
    And I fill in the "Delivery address line 1" input field with "3 Velstar Delivery Lane"
    And I fill in the "Delivery town" input field with "Hull"
    And I fill in the "Delivery postcode" input field with "HU1 1AA"
    And I click on the "Save changes" button
    Then I should eventually be redirected to the "job-detail" page
    And the "customer phone" should contain the text "07111111111"
    When I click precisely on the "Edit job" link
    Then I should be redirected to the "job-edit" page
    And the "Billing address line 1" should equal the value "2 Velstar Billing Road"
    And the "Billing postcode" should equal the value "YO1 1AA"
    And the "Delivery address line 1" should equal the value "3 Velstar Delivery Lane"
    And the "Delivery postcode" should equal the value "HU1 1AA"
