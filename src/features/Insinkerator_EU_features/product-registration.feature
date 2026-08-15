@regression
Feature: Product registration

  # Ported from P3Playwright's insinkerator_eu/tests/registration/
  # product-registration.test.ts. Scope: the EU domain
  # (staging.insinkerator-eu.work) only - the UK-domain form has its own
  # base URL and is deliberately out of scope here (see INSE-764 follow-up
  # in the source project).
  #
  # Place of purchase is marked required (an asterisk on its label) AND the
  # submit button stays disabled while it's empty - both the UI and backend
  # now agree on this field being mandatory.

  Background:
    Given I am on the "product-registration" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Germany" button if present

  @smoke
  Scenario: The en-gb registration form displays, with Place of purchase marked required
    Then the "registration first name input" should be displayed
    And the "registration last name input" should be displayed
    And the "registration email input" should be displayed
    And the "registration place of purchase input" should be displayed
    And the "registration serial number input" should be displayed
    And the "Submit" should be displayed
    And the "registration place of purchase label" should contain the text "*"

  Scenario: Leaving Place of purchase blank keeps the submit button disabled on en-gb
    When I fill in a freshly generated product registration except "placeOfPurchase", remembering it as "incomplete registration"
    Then the "Submit" should not be enabled

  Scenario: A fully completed en-gb registration submits successfully
    When I fill in a freshly generated product registration, remembering it as "engb registration"
    And I click on the "Submit" button
    Then the "success icon" should be displayed

  Scenario: A fully completed de registration submits successfully
    Given I navigate directly to the path "/de/product-registration"
    And I click on the "Accept cookies" button if present
    And I click on the "Select Germany" button if present
    When I fill in a freshly generated product registration, remembering it as "de registration"
    And I click on the "Submit" button
    Then the "success icon" should be displayed
