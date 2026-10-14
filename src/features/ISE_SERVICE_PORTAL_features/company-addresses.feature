@regression @creates-reference-data
Feature: Company addresses

  # ISE-SP.13 / IWS-56: a service company manages its own addresses. As
  # built (CONFIRMED live, 2026-10-14): only the Service Manager can open
  # Company addresses (/company/addresses, linked from the dashboard, not
  # the menu). Owner, Admin, Engineer and Developer all get 403 (covered in
  # access-control.feature). Addresses can be added, edited and removed;
  # Remove deletes straight away, with no confirmation. Another company's
  # address id by direct URL is 403.
  #
  # Open questions (asserted as built, not red): IWS-56 asks for one billing
  # address plus several shipping addresses, but the page has a single list
  # with no billing/shipping split. IWS-56 also says a new address should be
  # "available when starting a new job", but nothing in the job flow offers
  # these addresses yet (Step 1 only takes the installed address).
  #
  # Every address starts "Velstar Test" and each scenario removes its own.

  Background:
    Given I am navigating the page as a "manager" user
    When I click on the "Company addresses link" link
    Then I should be redirected to the "company-addresses" page

  @smoke
  Scenario: A Service Manager adds a company address and removes it
    When I click on the "Add address" link
    Then I should be redirected to the "company-address-new" page
    When I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with a unique value starting with "Velstar Test", remembering it as "address line"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Save address" button
    Then I should eventually be redirected to the "company-addresses" page
    And the "flash message" should contain the text "Address added."
    And the "address list" should contain the remembered "address line"
    When I click on the "Remove button" inside the "address row" containing the remembered "address line"
    Then the "flash message" should contain the text "Address removed."
    And the "address list" should not contain the remembered "address line"

  Scenario: A Service Manager edits a company address
    When I click on the "Add address" link
    Then I should be redirected to the "company-address-new" page
    When I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with a unique value starting with "Velstar Test", remembering it as "address line"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Save address" button
    Then I should eventually be redirected to the "company-addresses" page
    When I click on the "Edit link" inside the "address row" containing the remembered "address line"
    Then I should be redirected to the "company-address-edit" page
    And the "Address line 1" input field should contain the remembered "address line"
    When I fill in the "Address line 1" input field with a unique value starting with "Velstar Test Edited", remembering it as "edited address line"
    And I click on the "Save address" button
    Then I should eventually be redirected to the "company-addresses" page
    And the "address list" should contain the remembered "edited address line"
    When I click on the "Remove button" inside the "address row" containing the remembered "edited address line"
    Then the "flash message" should contain the text "Address removed."
    And the "address list" should not contain the remembered "edited address line"

  Scenario: An address needs line 1, town and postcode
    When I click on the "Add address" link
    Then I should be redirected to the "company-address-new" page
    When I click on the "Enter manually" button
    And I click on the "Save address" button
    Then the "Address line 1" input should be rejected as empty
    When I fill in the "Address line 1" input field with "Velstar Test Street"
    And I click on the "Save address" button
    Then the "Town" input should be rejected as empty
    When I fill in the "Town" input field with "Leeds"
    And I click on the "Save address" button
    Then the "Postcode" input should be rejected as empty
    And I should be redirected to the "company-address-new" page
