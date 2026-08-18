@regression
Feature: Quote Tool - Quotes List View

  # From KOOL-2026-08-17.json, "Quote Tool > Quotes List View" (cases
  # 477-485, 512). Runs as the "logged in" user (g.hajduk@9xb.com), which
  # has full staff Quote Builder access at /account/staff-quotes - the
  # separate "quotes user 2" account is a plain trade customer with only a
  # read-only Quotes section, not the staff tool tested here.
  #
  # Actual quote creation (477/479) and deletion (481) aren't automated
  # here: creating a real quote requires selecting a real customer/delivery
  # address and mutates live data, and deleting an existing quote would
  # destroy real records with no disposable one to safely target - same
  # caution as this project's registration test. 478 (missing fields) is
  # covered as a safe, non-submitting validation check instead: the CREATE
  # QUOTE button starts disabled and only enables once required fields are
  # filled.

  Background:
    Given I am navigating the page as a "logged in" user
    And I am on the "staff-quotes" page

  @smoke
  Scenario: Quotes list shows the expected columns
    Then the "quote table headers" should contain the text "Company Name"
    And the "quote table headers" should contain the text "Quote Reference"
    And the "quote table headers" should contain the text "Quote Name"
    And the "quote table headers" should contain the text "Status"
    And the "quote table headers" should contain the text "Created"
    And the "quote table headers" should contain the text "Created By"
    And the "quote table headers" should contain the text "Last Updated"
    And the "quote table headers" should contain the text "Last Updated By"
    And the "quote table headers" should contain the text "Sales Manager"
    And the "quote table headers" should contain the text "Delete"

  Scenario: Filtering by company name narrows the list to matching quotes
    When I fill in the "quote filter company name input" input field with "AEROCOOL"
    And I click on the "quote filter button" button
    Then the "quote table company name cells" should all contain the text "AEROCOOL"

  Scenario: Sorting by a column changes the row order
    When I remember the text of "quote table first row reference" as "quote ref before sort"
    And I click on the "quote created column sort icon" icon
    Then the "quote table first row reference" text should not equal the remembered "quote ref before sort"

  @smoke
  Scenario: Pagination moves to the next page
    When I click on the "quote pagination next button" button
    Then the "quote pagination indicator" should equal text "Page 2"

  @smoke
  Scenario: Viewing a quote's details shows the correct reference
    When I remember the text of "quote table first row reference" as "clicked quote reference"
    And I click on the "quote table first row reference" link
    Then the current URL should contain "/account/staff-quotes/"
    And the "quote detail reference" should contain the remembered "clicked quote reference"

  Scenario: Creating a new quote with missing required fields keeps Create disabled
    When I click on the "Create a New Quote" button
    Then the "create quote submit button" should not be enabled
