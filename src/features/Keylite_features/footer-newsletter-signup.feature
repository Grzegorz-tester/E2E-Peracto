@regression
Feature: Footer newsletter signup

  # The valid signup is a REAL one (agreed 2026-09-24) - it feeds
  # Keylite's newsletter list, so it uses a disposable, clearly-test
  # address. @submits-real-form keeps it off production. CONFIRMED live:
  # the server action returns {"success":"Thank you for subscribing to our
  # newsletter."}, shown in newsletter-form__alert (the input disappears).

  Scenario: An invalid email is rejected by the footer newsletter form
    Given I am navigating the page as a "guest" user
    And I am on the "home" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I fill in the "newsletter email" input field with "not-an-email"
    And I click on the "newsletter submit" button
    Then the "newsletter email" input should be rejected as invalid

  @submits-real-form
  Scenario: Subscribing with a valid email shows the success message
    Given I am navigating the page as a "guest" user
    And I am on the "home" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I fill in the "newsletter email" input field with a unique email, remembering it as "newsletter email address"
    And I click on the "newsletter submit" button
    Then the "newsletter alert" should contain the text "Thank you for subscribing to our newsletter."
