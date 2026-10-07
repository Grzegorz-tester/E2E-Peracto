@regression @runs-tasks
Feature: Scheduled tasks - Aquatherm export and product sync

  # ISE-SP.2, SP.5 and SP.6. Tasks (/admin/tasks) has a manual "Run now" for
  # each scheduled task. Runs are queued ("Pending") and picked up by a
  # background worker, hence the reload-until steps. Running both was
  # approved for staging by the user (2026-10-07).
  #
  # CONFIRMED live (2026-10-06/07):
  # - The Aquatherm export only has 6 columns (Job Reference, Customer Name,
  #   Service Company, Status, Invoice Subtotal, Invoice Total). SP.5 works
  #   from Aquatherm's 29-column reference (less 4 excluded columns); the SoW
  #   says several columns were still being defined. Asserted as built.
  # - Installation jobs are included in the export too. SP.5 describes the
  #   export as covering finalised warranty jobs, and SP.30 leaves
  #   Installation as an open question. Not asserted either way.
  # - With the recipient list empty (its normal state on staging) only the
  #   person who ran the export is notified ("1 recipients"); with nothing
  #   to export, nobody is ("No unexported invoices, nothing to export.").
  # - Export files in My files show "Expires: Never", although Settings says
  #   token-only share links expire after 72 hours. Open question.
  # - The product sync has failed every night since 2026-09-29, and fails
  #   when run manually too. Its log only says "Task failed." with no reason.

  Scenario: A completed Warranty job is in the next Aquatherm export with its totals
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
    And I click on the "Inside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    And I remember the part of the "job heading" text matching the pattern "(JOB-[0-9A-F]+)" as "job reference"
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-diagnosis" page
    When I select the "F-134 - Wiring fault" option from the "Fault code" dropdown
    And I click on the "Next" button
    Then I should be redirected to the "job-replacement-product" page
    When I click on the "Standard 460 product" element
    And I click on the "Next" button
    Then I should be redirected to the "job-service-info" page
    When I click on the "Next" button
    Then I should be redirected to the "job-service-date" page
    When I fill in the "Service date" date input field with the date 7 days from today
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
    When I fill in the "Part quantity" input field with "2"
    And I fill in the "Part number" input field with "VELSTAR-TEST-PART"
    And I fill in the "Part description" input field with "Velstar Test part"
    And I fill in the "Part price" input field with "10.00"
    And I fill in the "Labour" input field with "20.00"
    And I click on the "Next" button
    Then I should be redirected to the "job-notes" page
    When I click on the "Next" button
    Then I should be redirected to the "job-complete" page
    When I click on the "Submit" button
    Then the "completion message" should contain the text "This job will be included in the next Aquatherm export."
    # Owner runs the export: £85 call-out + 2 x £10 + £20 labour = £125.00,
    # £150.00 with VAT.
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "owner" user
    # SP.6: nominated users are told the file is ready. Adds a Velstar alias
    # to the (normally empty) recipient list for this run, then empties it.
    And I navigate directly to the path "/settings"
    And I fill in the "Aquatherm export recipients" input field with "grzegorz.hajduk+ise-sp-aquatherm@velstar.co.uk"
    And I click on the "Save notifications settings" button
    Then the "flash message" should contain the text "Notifications settings saved."
    When I navigate directly to the path "/admin/tasks"
    And I click on the "Aquatherm export task" link
    Then I should be redirected to the "task-detail" page
    When I remember the text of "latest run link" as "previous run"
    And I click on the "Run now" button
    And I reload the page until the "latest run link" no longer contains the remembered "previous run", for up to 120 seconds
    And I reload the page until the "latest run outcome" no longer contains the text "Pending", for up to 120 seconds
    Then the "latest run outcome" should contain the text "Success"
    When I click on the "latest run link" link
    Then I should be redirected to the "task-run" page
    And the "run logs" should contain the text "Exported"
    And the "run logs" should contain the text "Notification sent to 2 recipients."
    When I navigate directly to the path "/my/files"
    And I click on the "first file link" button, remembering the downloaded file as "export"
    Then the remembered "export" download's header row should contain the columns "Job Reference,Customer Name,Service Company,Status,Invoice Subtotal,Invoice Total"
    And the remembered "export" download should contain the remembered "job reference" on a line containing "125.00,150.00"
    # Only unexported invoices are exported: an immediate re-run has
    # nothing new to send.
    When I navigate directly to the path "/admin/tasks/aquatherm_export"
    And I remember the text of "latest run link" as "previous run"
    And I click on the "Run now" button
    And I reload the page until the "latest run link" no longer contains the remembered "previous run", for up to 120 seconds
    And I reload the page until the "latest run outcome" no longer contains the text "Pending", for up to 120 seconds
    And I click on the "latest run link" link
    Then I should be redirected to the "task-run" page
    And the "run logs" should contain the text "No unexported invoices, nothing to export."
    # Restore the recipient list.
    When I navigate directly to the path "/settings"
    And I fill in the "Aquatherm export recipients" input field with ""
    And I click on the "Save notifications settings" button
    Then the "flash message" should contain the text "Notifications settings saved."

  Scenario: The export file's share link opens without a login
    # SP.6: Aquatherm must be able to get the file without managing a login.
    # Settings: token-only share links expire after 72 hours.
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/admin/tasks/aquatherm_export"
    And I remember the text of "latest run link" as "previous run"
    And I click on the "Run now" button
    And I reload the page until the "latest run link" no longer contains the remembered "previous run", for up to 120 seconds
    And I reload the page until the "latest run outcome" no longer contains the text "Pending", for up to 120 seconds
    Then the "latest run outcome" should contain the text "Success"
    When I navigate directly to the path "/my/files"
    And I remember the "href" attribute of the "first file link" as "share link"
    And I navigate directly to the path "/logout"
    Then requesting the remembered path "share link" should return status 200 with content-type "text/csv"

  Scenario: The product sync completes successfully
    # CONFIRMED live (2026-10-06/07): currently FAILS - every run since
    # 2026-09-29 (nightly and manual) ends in "Failure" with only "Task
    # failed." in the log. SP.2's product feed from the ISE UK website is
    # broken on staging. Left red deliberately.
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/admin/tasks"
    And I click on the "Product sync task" link
    Then I should be redirected to the "task-detail" page
    When I remember the text of "latest run link" as "previous run"
    And I click on the "Run now" button
    And I reload the page until the "latest run link" no longer contains the remembered "previous run", for up to 120 seconds
    And I reload the page until the "latest run outcome" no longer contains the text "Pending", for up to 120 seconds
    Then the "latest run outcome" should contain the text "Success"
