@regression @creates-reference-data
Feature: Service company management

  # ISE-SP.16 / SP.18 service company management, run as the Owner.
  # Companies can't be deleted, only made inactive, so every run leaves
  # "VT <timestamp>" companies behind (most of them inactive).
  #
  # CONFIRMED live (2026-10-07), differs from SoW: a company only has a name
  # and an Active flag. SP.13's billing address and multiple shipping
  # addresses aren't on the company at all (billing and delivery addresses
  # exist per job instead, on the Owner/Admin "Edit job" form).

  Background:
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/companies"
    And I click on the "New company" link
    Then I should be redirected to the "company-new" page
    When I fill in the "Company name" input field with a unique value starting with "VT", remembering it as "company name"
    And I ensure the "Active" checkbox is checked
    And I click on the "Save company" button
    Then I should be redirected to the "companies" page
    When I fill in the "Search companies" input field with the remembered "company name"
    And I press Enter in the "Search companies" input field
    Then the "first record title" should contain the remembered "company name"

  @smoke
  Scenario: The Owner adds a service company and can raise a job for it
    Then the "first record badge" should contain the text "Active"
    When I navigate directly to the path "/job/new"
    Then the "Service company" should contain the remembered "company name"

  Scenario: The Owner renames a service company
    When I click on the "first record Edit" link
    Then I should be redirected to the "company-edit" page
    When I fill in the "Company name" input field with a unique value starting with "VT renamed", remembering it as "new company name"
    And I click on the "Save company" button
    Then I should be redirected to the "companies" page
    When I fill in the "Search companies" input field with the remembered "new company name"
    And I press Enter in the "Search companies" input field
    Then the "first record title" should contain the remembered "new company name"
    When I click on the "first record Edit" link
    Then I should be redirected to the "company-edit" page
    When I uncheck the "Active"
    And I click on the "Save company" button
    Then I should be redirected to the "companies" page

  Scenario: An inactive company can't be chosen for a new job
    When I click on the "first record Edit" link
    Then I should be redirected to the "company-edit" page
    When I uncheck the "Active"
    And I click on the "Save company" button
    Then I should be redirected to the "companies" page
    When I navigate directly to the path "/companies?filter=inactive"
    And I fill in the "Search companies" input field with the remembered "company name"
    And I press Enter in the "Search companies" input field
    Then the "first record title" should contain the remembered "company name"
    And the "first record badge" should contain the text "Inactive"
    When I navigate directly to the path "/job/new"
    Then the "Service company" should not contain the remembered "company name"
    And the "Service company" should contain the text "Test Company"

  Scenario: A company can override the standard call-out charge
    # Company-level overrides of the global invoicing settings. Done on a
    # throwaway VT company so nothing real changes.
    When I click on the "first record Settings" link
    Then I should be redirected to the "company-settings" page
    And the "company settings page" should contain the text "Global default: 8500"
    When I fill in the "Call-out charge override" input field with "9100"
    And I click on the "Save invoicing settings" button
    Then the "flash message" should contain the text "saved"
    When I reload the page
    Then the "Call-out charge override" should equal the value "9100"
    When I navigate directly to the path "/settings/invoicing/callout_amount/company-overrides"
    Then the "overrides list" should contain the remembered "company name"
    When I navigate directly to the path "/companies"
    And I fill in the "Search companies" input field with the remembered "company name"
    And I press Enter in the "Search companies" input field
    Then the "first record title" should contain the remembered "company name"
    When I click on the "first record Edit" link
    Then I should be redirected to the "company-edit" page
    When I uncheck the "Active"
    And I click on the "Save company" button
    Then I should be redirected to the "companies" page
