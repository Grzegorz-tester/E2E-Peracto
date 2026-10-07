@regression @creates-jobs
Feature: Invoicing and charges

  # ISE-SP.31 / SP.32: the Invoicing step's editable parts table, labour,
  # pre-filled call-out charge and server-side VAT/total. The single-part
  # case and the (missing) live recalculation are in the journey features;
  # this covers several parts at once.
  #
  # CONFIRMED DEFECT (live, 2026-10-07): "Add part" does nothing on the
  # Invoicing step - the button has data-action="collection#add" but no
  # element on the page carries data-controller="collection", so the
  # action is never wired up. An engineer can only invoice ONE part. The
  # page also logs a 404 for a missing resource and a page error. This
  # scenario stays red until it's fixed.

  Scenario: An engineer can invoice several parts, which add up into the total
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
    And I remember the current URL path as "invoicing step"
    # 3 x £12.50 + 1 x £7.25 = £44.75 parts; + £30 labour + £85 call-out
    # = £159.75; VAT £31.95; total £191.70.
    When I fill in the "Part quantity" input field with "3"
    And I fill in the "Part number" input field with "VELSTAR-TEST-A"
    And I fill in the "Part description" input field with "Velstar Test part A"
    And I fill in the "Part price" input field with "12.50"
    And I click precisely on the "Add part" button
    Then the "Second part quantity" should be visible
    When I fill in the "Second part quantity" input field with "1"
    And I fill in the "Second part number" input field with "VELSTAR-TEST-B"
    And I fill in the "Second part description" input field with "Velstar Test part B"
    And I fill in the "Second part price" input field with "7.25"
    And I fill in the "Labour" input field with "30.00"
    And I click on the "Next" button
    Then I should be redirected to the "job-notes" page
    When I navigate directly to the remembered path "invoicing step"
    Then the "Parts total" should equal text "£44.75"
    And the "VAT amount" should equal text "£31.95"
    And the "Total amount" should equal text "£191.70"
    And the "Second part price" should equal the value "7.25"

  Scenario: A flat mileage amount carries through to the invoice
    # SP.23: outside the radius, the engineer can claim a flat amount instead
    # of excess miles. Flat £25.00 -> authorised by the Owner -> invoiced.
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
    And I click on the "Installation option" element
    And I click on the "Outside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Continue job" link
    Then I should be redirected to the "job-replacement-product" page
    When I click on the "Standard 460 product" element
    And I click on the "Next" button
    Then I should be redirected to the "job-service-info" page
    When I fill in the "Flat amount" input field with "25.00"
    And I fill in the "Mileage comments" input field with "Velstar Test - flat amount"
    And I click on the "Next" button
    Then I should be redirected to the "job-authorisation" page
    And the "authorisation page" should contain the text "25.00"
    And I remember the current URL path as "authorisation step"
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "owner" user
    And I navigate directly to the remembered path "authorisation step"
    And I fill in the "Authorisation code" input field with "VELSTAR-TEST-AUTH"
    And I click on the "Authorise & Continue" button
    Then I should be redirected to the "job-service-date" page
    And I remember the current URL path as "service date step"
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "engineer" user
    And I navigate directly to the remembered path "service date step"
    And I fill in the "Service date" date input field with the date 7 days from today
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
    And the "invoice summary" should contain the text "£25.00"
