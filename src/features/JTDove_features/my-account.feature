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
