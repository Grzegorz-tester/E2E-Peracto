@regression @changes-global-settings
Feature: Settings

  # ISE-SP.16 / SP.18: Owner-only Settings (/settings). These are GLOBAL
  # and shared by everyone using staging, so every scenario restores the
  # original value before it ends (approved for staging by the user,
  # 2026-10-07). If a scenario fails part-way, check Settings by hand:
  # call-out 8500, mileage 45, radius 0, token link expiry 72, every
  # notification recipient list empty, "Can authorise mileage" unticked
  # for the Admin test account (user 79).
  #
  # The Aquatherm export recipients setting is covered in tasks.feature,
  # since the export only notifies anyone when it has jobs to export.
  #
  # Each section saves on its own button, with "<Section> settings saved.".

  Background:
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/settings"
    Then I should be redirected to the "settings" page

  Scenario: The Owner changes the support phone number and restores it
    When I remember the value of the "Support phone number" input field as "original phone"
    And I fill in the "Support phone number" input field with "0800 000 0000"
    And I click on the "Save general settings" button
    Then the "flash message" should contain the text "General settings saved."
    When I reload the page
    Then the "Support phone number" should equal the value "0800 000 0000"
    When I fill in the "Support phone number" input field with the remembered "original phone"
    And I click on the "Save general settings" button
    Then the "flash message" should contain the text "General settings saved."
    And the "Support phone number" input field should have the remembered "original phone"

  Scenario: A new standard call-out charge is used on new job invoices
    When I fill in the "Standard call-out charge" input field with "8800"
    And I click on the "Save invoicing settings" button
    Then the "flash message" should contain the text "Invoicing settings saved."
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "engineer" user
    And I click on the "New job" link
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
    And the "Standard call-out amount" should equal text "£88.00"
    # Restore the global default.
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "owner" user
    And I navigate directly to the path "/settings"
    And I fill in the "Standard call-out charge" input field with "8500"
    And I click on the "Save invoicing settings" button
    Then the "flash message" should contain the text "Invoicing settings saved."
    And the "Standard call-out charge" should equal the value "8500"

  Scenario: The Owner gives one user the mileage permission and takes it away
    When I navigate directly to the path "/settings/user/79"
    Then I should be redirected to the "user-settings" page
    And the "user settings page" should contain the text "Global default: No"
    When I ensure the "Can authorise mileage" checkbox is checked
    And I click on the "Save job authorisation settings" button
    Then the "flash message" should contain the text "saved"
    When I navigate directly to the path "/settings/job_authorisation/can_authorise_mileage/user-overrides"
    Then the "overrides list" should contain the text "grzegorz.hajduk+admin@velstar.co.uk"
    When I navigate directly to the path "/settings/user/79"
    And I uncheck the "Can authorise mileage"
    And I click on the "Save job authorisation settings" button
    Then the "flash message" should contain the text "saved"

  Scenario: The Owner changes the share link expiry and restores it
    When I fill in the "Token link expiry" input field with "48"
    And I click on the "Save file share settings" button
    Then the "flash message" should contain the text "File Share settings saved."
    When I reload the page
    Then the "Token link expiry" should equal the value "48"
    When I fill in the "Token link expiry" input field with "72"
    And I click on the "Save file share settings" button
    Then the "flash message" should contain the text "File Share settings saved."
    And the "Token link expiry" should equal the value "72"
