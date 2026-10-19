@regression
Feature: Quick enquiry form

  Background:
    Given I navigate directly to the path "/quick-enquiry-form"
    And I click on the "Accept cookies" button if present

  Scenario: Submitting the form with all required fields empty is rejected
    When I click on the "Send" button
    Then the "Name" input should be rejected as empty
    And the "Email address" input should be rejected as empty
    And the "Telephone" input should be rejected as empty
    And the "Message" input should be rejected as empty

  Scenario: Submitting the form with a malformed email is rejected
    When I fill in the "Name" input field with "Playwright QA Test"
    And I fill in the "Email address" input field with "not-an-email"
    And I fill in the "Telephone" input field with "07700900000"
    And I fill in the "Message" input field with "Automated Playwright test enquiry - please ignore."
    And I click on the "Send" button
    Then the "Email address" input should be rejected as invalid

  @smoke
  Scenario: A valid submission reaches the backend
    When I fill in the "Name" input field with "Playwright QA Test"
    And I fill in the "Email address" input field with a unique guest email
    And I fill in the "Telephone" input field with "07700900000"
    And I fill in the "Message" input field with "Automated Playwright test enquiry - please ignore."
    And I click on the "Send" button and note the response status of a request to "/form-submissions"
    Then the noted response status should equal 201
