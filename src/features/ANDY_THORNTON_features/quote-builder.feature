@regression @not-on-production @serial
Feature: Quote Builder

  # Smoke cases 36-43 (AN-2026-11-19.json), added 2026-11-19 for AT-185
  # (which names "quotes" in its post-deploy checklist) and AT-201.
  #
  # Confirmed live on staging 2026-11-19:
  # - Quote Builder access comes from the "Sales Team" customer group
  #   (access_all_quotes). The "logged in" account is in it (and is also
  #   ROLE_ADMIN); the "non admin" account is in the plain "User" group, which
  #   gets Moodboards instead and is redirected from /account/quotes to /account.
  # - Quotes and moodboards are the same records: this account's moodboards
  #   list shows its quotes. So every quote here is named
  #   "Velstar Test Quote <timestamp>" and the Background sweeps that prefix
  #   (the account is SHARED with other people's real quotes; never touch them).
  # - The detail header has Edit, Moodboard view and Delete icons, but NO
  #   Duplicate icon (case 38 expects one): duplicating is only on the list.
  # - KNOWN SITE DEFECT (pre-existing, also on production 2026-11-19): the
  #   "You have unsaved changes" bar shows on every quote as soon as it loads
  #   and stays after a successful save, so case 39's "the bar disappears"
  #   can't be the save check. The "Quote was successfully updated!" toast and
  #   the item persisting after a reload are used instead.
  # - Each quote line has two quantity pickers: the first is the unit PRICE,
  #   the second the QUANTITY.
  #
  # @serial: the logged-in account's quotes are shared state.

  Background:
    Given I am navigating the page as a "logged in" user
    And I click on the "Allow all cookies" button if present
    When I am on the "account-quotes" page
    And I delete every "quote rows" whose "quote name cell" starts with "Velstar Test Quote", using the "quote delete" and "confirm quote delete"


  # Case 36
  Scenario: The Quotes list is in the account navigation and shows its filters, table and create link
    When I am on the "account" page
    Then the "account nav Quotes link" should be displayed
    When I click on the "account nav Quotes link" link
    Then I should eventually be redirected to the "account-quotes" page
    And the "quotes heading" should contain the text "Quotes"
    And the "quotes filters" should be displayed
    And the "quote name filter" should be displayed
    And the "quotes header row" should be displayed
    And the "Create a new Quote" should be displayed


  # Cases 37 and 38
  Scenario: Creating a quote needs all three required fields, and opens its detail page with its controls
    When I click on the "Create a new Quote" button
    Then the "create quote dialog" should be displayed
    And the "Create Quote" should not be enabled
    When I fill in the "create quote name" input field with a unique value starting with "Velstar Test Quote", remembering it as "quote name"
    Then the "Create Quote" should not be enabled
    When I fill in the "create quote customer name" input field with "Velstar Test"
    Then the "Create Quote" should not be enabled
    When I fill in the "create quote reference" input field with "VELSTAR-TEST"
    Then the "Create Quote" should be enabled
    When I click on the "Create Quote" button
    Then I should eventually be redirected to the "account-quote-detail" page
    And the "quote title" should contain the remembered "quote name"
    And the "quote details" should contain the text "VELSTAR-TEST"
    And the "quote details" should contain the text "Created By"
    And the "quote details" should contain the text "Date Created"
    # Case 38: the detail page's actions and controls.
    And the "Edit quote icon" should be displayed
    And the "Moodboard view icon" should be displayed
    And the "Delete quote icon" should be displayed
    And the "Generate Quote" should be displayed
    And the "Show VAT in Total" should be displayed
    And the "new section name" should be displayed
    And the "Add section" should be displayed
    When I am on the "account-quotes" page
    Then the "quotes table" should contain the remembered "quote name"


  # Case 38: the VAT toggle is interactive.
  Scenario: The Show VAT in Total toggle switches on and off
    When I click on the "Create a new Quote" button
    And I fill in the "create quote name" input field with a unique value starting with "Velstar Test Quote", remembering it as "quote name"
    And I fill in the "create quote customer name" input field with "Velstar Test"
    And I fill in the "create quote reference" input field with "VELSTAR-TEST"
    And I click on the "Create Quote" button
    Then I should eventually be redirected to the "account-quote-detail" page
    And the "Show VAT toggle" radio button should be checked
    When I click on the "Show VAT in Total" button
    Then the "Show VAT toggle" radio button should not be checked
    When I click on the "Show VAT in Total" button
    Then the "Show VAT toggle" radio button should be checked


  # Case 39
  Scenario: Adding a section and a catalogue item, changing its quantity and saving persists after a reload
    When I click on the "Create a new Quote" button
    And I fill in the "create quote name" input field with a unique value starting with "Velstar Test Quote", remembering it as "quote name"
    And I fill in the "create quote customer name" input field with "Velstar Test"
    And I fill in the "create quote reference" input field with "VELSTAR-TEST"
    And I click on the "Create Quote" button
    Then I should eventually be redirected to the "account-quote-detail" page
    And I wait for the page to settle

    When I fill in the "new section name" input field with "Velstar Test Section"
    And I click on the "Add section" button
    Then the "quote section" should contain the text "Velstar Test Section"
    And the "Include in Quote" should be displayed
    And the "catalogue search" should be displayed
    And the "Add Custom Item" should be displayed

    When I fill in the "catalogue search" input field with "ATFUOF1104"
    Then the "catalogue results" should contain the text "Vienna Stackable Side Chair"
    And the "catalogue results" should contain the text "£102.00"
    When I click on the "catalogue first result" element
    Then the "quote item name" should equal the value "Vienna Stackable Side Chair"
    And the "quote item sku" should equal the value "ATFUOF1104"
    And the "quote item quantity" should equal the value "1"
    And the "unsaved changes bar" should be displayed
    And the "Reset Changes" should be displayed

    When I fill in the "quote item quantity" input field with "3"
    And I click on the "Save Changes" button
    Then the "toast" should contain the text "Quote was successfully updated!"
    When I wait for the page to settle
    And I reload the page
    And I wait for the page to settle
    Then the "quote section" should contain the text "Velstar Test Section"
    And the "quote item name" should equal the value "Vienna Stackable Side Chair"
    And the "quote item quantity" should equal the value "3"


  # Case 40
  Scenario: Generate Quote offers Open in New Tab and Download, and the download is a real PDF
    When I click on the "Create a new Quote" button
    And I fill in the "create quote name" input field with a unique value starting with "Velstar Test Quote", remembering it as "quote name"
    And I fill in the "create quote customer name" input field with "Velstar Test"
    And I fill in the "create quote reference" input field with "VELSTAR-TEST"
    And I click on the "Create Quote" button
    Then I should eventually be redirected to the "account-quote-detail" page
    And I wait for the page to settle
    When I fill in the "new section name" input field with "Velstar Test Section"
    And I click on the "Add section" button
    And I fill in the "catalogue search" input field with "ATFUOF1104"
    And I click on the "catalogue first result" element
    And I click on the "Save Changes" button
    Then the "toast" should contain the text "Quote was successfully updated!"

    When I click on the "Generate Quote" button
    Then the "Open in New Tab" should be displayed
    And the "Download quote PDF" should be displayed
    When I click on the "Download quote PDF" button, remembering the downloaded file as "quote pdf"
    Then the remembered "quote pdf" download should not be empty
    And the remembered "quote pdf" download should start with the text "%PDF"


  # Cases 41 and 42
  Scenario: Duplicating a quote from the list, then deleting both
    When I click on the "Create a new Quote" button
    And I fill in the "create quote name" input field with a unique value starting with "Velstar Test Quote", remembering it as "quote name"
    And I fill in the "create quote customer name" input field with "Velstar Test"
    And I fill in the "create quote reference" input field with "VELSTAR-TEST"
    And I click on the "Create Quote" button
    Then I should eventually be redirected to the "account-quote-detail" page

    # Case 41: the modal is pre-filled "Copy of <name>"; it's renamed so the
    # Background's prefix sweep can find it if the scenario fails midway.
    When I am on the "account-quotes" page
    And I click on the "quote duplicate" inside the "quote rows" containing the remembered "quote name"
    Then the "duplicate quote dialog" should be displayed
    And the "duplicate quote name" input field should contain the remembered "quote name"
    When I fill in the "duplicate quote name" input field with a unique value starting with "Velstar Test Quote Copy", remembering it as "copy name"
    And I click on the "confirm duplicate quote" button
    Then the "toast" should contain the text "Quote successfully duplicated!"
    When I wait for the page to settle
    And I reload the page
    Then the "quotes table" should contain the remembered "copy name"
    And the "quotes table" should contain the remembered "quote name"

    # Case 42
    When I click on the "quote delete" inside the "quote rows" containing the remembered "copy name"
    Then the "delete quote dialog" should contain the text "This action cannot be undone"
    When I click on the "confirm quote delete" button
    Then the "toast" should contain the text "Quote successfully deleted!"
    When I wait for the page to settle
    And I reload the page
    Then the "quotes table" should not contain the remembered "copy name"
    And the "quotes table" should contain the remembered "quote name"
