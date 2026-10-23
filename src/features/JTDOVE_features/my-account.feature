@regression
Feature: My Dove account area

  # Rewritten 2026-10-05 against the live account area. The shared test
  # account is a real trade account (account number 103128, greeted as
  # "Fred") with real invoice history, so everything here is read-only -
  # the Make a Payment form is never submitted.

  Background:
    Given I am navigating the page as a "logged in" user


  Scenario: Dashboard greets the customer with their account number
    Given I am on the "account" page
    And I wait for the page to settle
    Then the "account welcome" should contain the text "Hi"
    And the "account menu" should contain the text "Account Number: 103128"
    And the "dashboard cards" should be displayed
    And the "Sign Out" should be displayed


  Scenario Outline: The "<item>" account menu item opens its page
    Given I am on the "account" page
    And I wait for the page to settle
    When I click on the "<item> menu item" element, retrying until redirected to the "<page>" page
    Examples:
      | item           | page                   |
      | Profile        | account-profile        |
      | Address Book   | account-address-book   |
      | Invoices       | account-invoices       |
      | My Lists       | account-wishlist       |
      | Make a Payment | account-make-a-payment |
      | Dashboard      | account                |


  Scenario: Profile shows the customer's details
    Given I am on the "account-profile" page
    And I wait for the page to settle
    Then the "profile email" should equal the value "grzegorz.hajduk@velstar.co.uk"
    And the "profile first name" should be displayed
    And the "profile last name" should be displayed
    And the "profile contact number" should be displayed
    And the "Save changes" should be displayed


  Scenario: Address book lists delivery and billing addresses
    Given I am on the "account-address-book" page
    And I wait for the page to settle
    Then the "first delivery address" should be displayed
    And the "first billing address" should be displayed
    And the "Add delivery address" should be displayed
    And the "Add billing address" should be displayed


  Scenario: Invoices lists the account's invoices
    Given I am on the "account-invoices" page
    And I wait for the page to settle
    Then the "invoices title" should be displayed
    And the "invoices table header" should be displayed
    And the "first invoice document number" should be displayed


  Scenario: Invoices can be filtered by document number
    Given I am on the "account-invoices" page
    And I wait for the page to settle
    And I remember the text of "first invoice document number" as "document number"
    When I fill in the "document number filter" input field with the remembered "document number"
    And I wait for the search results to update
    And the "first invoice document number" text should equal the remembered "document number"


  Scenario: Make a Payment shows the online and BACS options without paying
    Given I am on the "account-make-a-payment" page
    And I wait for the page to settle
    Then the "make a payment online" should be displayed
    And the "payment billing address" should be displayed
    And the "MAKE A PAYMENT" should be displayed
    And the "BACS details" should be displayed


  # Manual regression cases 134, 135, 137, 146-148 and 153 (added 2026-10-22).
  Scenario: Dashboard shows the default delivery and billing addresses
    Given I am on the "account" page
    And I wait for the page to settle
    Then the "Delivery Address default label" should contain the text "Default address"
    And the "Billing Address default label" should contain the text "Default address"
    # Smoke case 203: JT Dove has no orders page; the dashboard's Recent
    # Orders card is where orders are listed.
    And the "Recent Orders card" should be displayed
    When I click on the "Delivery Address View all" link, retrying until redirected to the "account-address-book" page


  # The active item carries a plain "bg-brand-light-grey" class; every item
  # also has "hover:bg-brand-light-grey", hence the leading whitespace match.
  Scenario: The current account section is highlighted in the menu
    Given I am on the "account-profile" page
    And I wait for the page to settle
    Then the "Profile menu item" should have class "\sbg-brand-light-grey"
    And the "Dashboard menu item" should not have class "\sbg-brand-light-grey"


  # Only checks native validation; nothing is saved. Contact number is
  # optional on JT Dove (the manual case lists Mobile as mandatory). Email
  # isn't covered here: it uses the site's own validation, not the browser's.
  Scenario: Profile requires first name and last name
    Given I am on the "account-profile" page
    And I wait for the page to settle
    When I fill in the "profile first name" input field with ""
    And I fill in the "profile last name" input field with ""
    Then the "profile first name" input should be rejected as empty
    And the "profile last name" input should be rejected as empty


  # Every invoice on the shared account is Paid, so the status filter is
  # checked by selecting Paid and confirming nothing else is listed.
  Scenario: Invoices can be filtered by status and the filters reset
    Given I am on the "account-invoices" page
    And I wait for the page to settle
    When I click on the "Status filter" element
    And I click on the "Paid status option" element
    And I wait for the search results to update
    Then the "invoice statuses" should all contain the text "Paid"
    When I click on the "Reset filters" button
    Then the "Status filter" should contain the text "Status"


  Scenario: Invoices pagination moves between pages
    Given I am on the "account-invoices" page
    And I wait for the page to settle
    And I remember the text of "first invoice document number" as "page one first invoice"
    When I click on the "invoices next page" button
    And I wait for the search results to update
    Then the "first invoice document number" text should not equal the remembered "page one first invoice"
    When I click on the "invoices previous page" button
    And I wait for the search results to update
    Then the "first invoice document number" text should equal the remembered "page one first invoice"


  Scenario: An invoice can be downloaded
    Given I am on the "account-invoices" page
    And I wait for the page to settle
    When I click on the "first invoice download" button, remembering the downloaded file as "invoice"
    Then the remembered "invoice" download should not be empty


  # Never submits a payment (shared account rule). The shared account owes
  # nothing (every invoice is Paid), so any amount is over its balance and
  # the button must stay disabled with an explanation (confirmed live
  # 2026-10-22).
  Scenario: Make a Payment rejects an amount above the account balance
    Given I am on the "account-make-a-payment" page
    And I wait for the page to settle
    Then the "MAKE A PAYMENT" should not be enabled
    When I fill in the "payment amount" input field with "10.00"
    Then the "payment balance message" should be displayed
    And the "MAKE A PAYMENT" should not be enabled
