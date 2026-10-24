@regression
Feature: Footer newsletter sign-up

  # Ported from Insinkerator_EU's footer-newsletter-signup.feature. The
  # newsletter form lives in the site footer, present on every page, and is
  # a native <input type="email" required> with no custom client-side
  # validation UI - empty/malformed submissions are asserted via the
  # input's own validity state, not a rendered error message.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: Newsletter form rejects empty and malformed email addresses
    Then the "newsletter form" should be displayed
    And the "newsletter email input" should be displayed
    And the "newsletter submit button" should be displayed

    When I fill in the "newsletter email input" input field with ""
    And I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as empty
    And the "newsletter alert" should not be displayed

    When I fill in the "newsletter email input" input field with "not-an-email"
    And I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as invalid
    And the "newsletter alert" should not be displayed

  # Split out 2026-10-24: this subscribes a real (Velstar-owned) address, so
  # it is tagged @submits-real-form and never runs on INSINKERATOR_PROD.
  @smoke
  @submits-real-form
  Scenario: A valid email address subscribes to the newsletter
    When I fill in the "newsletter email input" input field with a unique guest email
    And I click on the "newsletter submit button" button
    Then the "newsletter alert" should contain the text "Thank you for subscribing"
