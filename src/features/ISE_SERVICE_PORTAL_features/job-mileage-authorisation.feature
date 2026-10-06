@regression @creates-jobs
Feature: Mileage authorisation

  # ISE-SP.23 and SP.24: a job outside the standard call-out radius takes an
  # excess mileage (or flat amount) claim and needs authorising before it
  # can go ahead. The authorisation code can only be entered by an Owner, or
  # an Admin with "can authorise mileage".
  #
  # CONFIRMED live (2026-10-06): the Engineer sees the code field disabled,
  # with no button and "Waiting on someone else to complete this step.".
  # Admin and Owner get an enabled field and "Authorise & Continue". The
  # +admin test account can authorise. The permission's default is set in
  # Settings with no per-user overrides, so an Admin WITHOUT the permission
  # isn't covered: that needs a second Admin account, or an override that
  # would change behaviour for every Admin on staging.
  #
  # Submitting the claim sends the mileage authorisation request email
  # (SP.34). Authorising releases the order: the status goes Awaiting
  # authorisation -> Awaiting part.

  Background:
    Given I am navigating the page as a "engineer" user
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
    And I click on the "Warranty Service option" element
    And I click on the "Outside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-diagnosis" page
    When I select the "ELEC-04 - Trips circuit breaker" option from the "Complaint code" dropdown
    And I select the "F-134 - Wiring fault" option from the "Fault code" dropdown
    And I click on the "Next" button
    Then I should be redirected to the "job-replacement-product" page
    When I click on the "Standard 460 product" element
    And I click on the "Next" button
    Then I should be redirected to the "job-service-info" page
    When I fill in the "Excess miles" input field with "10"
    And I fill in the "Mileage comments" input field with "Velstar Test - automated E2E run"
    And I click on the "Next" button
    Then I should be redirected to the "job-authorisation" page
    And the "job summary" should contain the text "Awaiting authorisation"
    And I remember the current URL path as "authorisation step"

  Scenario: The Engineer can't enter the authorisation code
    Then the "waiting message" should be displayed
    And the "Authorisation code" should not be enabled
    And the "Authorise & Continue" should not be displayed

  Scenario: An Admin with the mileage permission can authorise
    # Checks the control only; doesn't submit, so the job stays pending.
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "admin" user
    And I navigate directly to the remembered path "authorisation step"
    Then the "Authorisation code" should be enabled
    And the "Authorise & Continue" should be displayed

  @smoke
  Scenario: The Owner authorises and the mileage carries through to the invoice
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "owner" user
    And I navigate directly to the remembered path "authorisation step"
    And I fill in the "Authorisation code" input field with "VELSTAR-TEST-AUTH"
    And I click on the "Authorise & Continue" button
    Then I should be redirected to the "job-service-date" page
    And the "job summary" should contain the text "Awaiting part"
    And I remember the current URL path as "service date step"
    # Back to the Engineer to finish the service day and reach invoicing:
    # 10 excess miles at the default 45p/mile = £4.50 (SP.31). Goes straight
    # to Service date rather than via "Continue job", which is broken
    # (see job-installation-journey.feature).
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "engineer" user
    And I navigate directly to the remembered path "service date step"
    And I fill in the "Service date" date input field with the date 7 days from today
    And I click on the "Book & Continue" button
    Then I should be redirected to the "job-current-setup" page
    When I upload the "velstar-test-job-photo.jpg" file to the "On-arrival photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-new-setup" page
    When I fill in the "New product serial number" input field with "VELSTAR-TEST-SN"
    And I upload the "velstar-test-job-photo.jpg" file to the "Above sink photo" input
    And I upload the "velstar-test-job-photo.jpg" file to the "Below sink photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-signature" page
    When I upload the "velstar-test-job-photo.jpg" file to the "Signature photo" input
    And I click on the "Next" button
    Then I should be redirected to the "job-invoicing" page
    And the "Excess mileage amount" should equal text "£4.50"
