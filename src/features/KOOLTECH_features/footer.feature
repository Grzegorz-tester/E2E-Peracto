@regression
Feature: Footer newsletter sign-up and links

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: Newsletter form validates the email address and confirms a successful sign-up
    Then the "newsletter form" should be displayed
    And the "newsletter email input" should be displayed
    And the "newsletter submit button" should be displayed

    # The email field is a plain text input (no native type="email"
    # validation) - "not a real address" is rejected by the app's own JS,
    # not the browser, so this is asserted via the rendered error message
    # rather than the input's validity state.
    When I fill in the "newsletter email input" input field with "not-an-email"
    And I click on the "newsletter submit button" button
    Then the "newsletter error message" should contain the text "Please enter a valid email address."

    When I fill in the "newsletter email input" input field with a unique guest email
    And I click on the "newsletter submit button" button
    Then the "newsletter form" should contain the text "Thank you, your email address has been submitted."

  @smoke
  Scenario: Footer links all resolve without a client or server error
    Then all "footer" links should resolve without an error
