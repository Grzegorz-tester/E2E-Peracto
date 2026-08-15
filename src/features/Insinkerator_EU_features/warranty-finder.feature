@regression
Feature: Warranty finder

  # Ported from P3Playwright's insinkerator_eu/tests/warranty/
  # warranty-finder.test.ts (INSE-764/INSE-770). Not gated by the selected
  # country (unlike ecommerce features elsewhere in this project) - works
  # identically regardless of which country the mandatory fresh-load modal
  # is dismissed with.

  Background:
    Given I am on the "warranty-finder" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Germany" button if present

  @smoke
  Scenario: User can see the warranty finder form, and the submit button is disabled until both fields are filled
    Then the "warranty last name input" should be displayed
    And the "warranty serial number input" should be displayed
    And the "warranty submit button" should not be enabled

  Scenario: Looking up a warranty with no matching registration shows a not-found message with a contact CTA
    When I fill in the "warranty last name input" input field with "Smith"
    And I fill in the "warranty serial number input" input field with a unique value
    And I click on the "warranty submit button" button
    Then the "warranty not found alert" should contain the text "unable to locate your information"
    And the "warranty get in touch link" should be displayed

  # Avoids depending on any fixed/pre-seeded record, since the finder only
  # ever matches an exact last name + serial number pair - registers a fresh
  # product moments earlier instead.
  Scenario: Looking up a warranty for a freshly registered product returns a success message with the registration date, product and serial number
    Given I navigate directly to the path "/en-gb/product-registration"
    And I click on the "Accept cookies" button if present
    And I click on the "Select Germany" button if present
    When I fill in a freshly generated product registration, remembering it as "warranty registration"
    And I click on the "Submit" button
    Then the "success icon" should be displayed

    When I am on the "warranty-finder" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Germany" button if present
    And I look up the warranty using the remembered product registration "warranty registration"
    Then the warranty lookup should succeed for "Standard 460" using the remembered registration "warranty registration"
