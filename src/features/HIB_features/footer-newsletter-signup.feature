@regression
Feature: Footer and newsletter sign-up

  # Built 2026-09-29 from a live inspection of feature-hib-170. Every internal
  # footer page is also rendered by health-check.feature; this covers the
  # footer itself and the "Stay Inspired" sign-up.
  #
  # NEVER submit the newsletter form, on any environment: "Subscribe" opens
  # MailerLite form UWRyi4 (account 15129), which is the SAME live form on
  # the release branch as on production (confirmed live) - a submission
  # from staging lands on HIB's real marketing list. These scenarios only
  # check the form opens.
  #
  # The Subscribe link's own data-testid is "account-menu__logout" (a
  # copy-paste leftover on HIB's side), so it's matched by text inside
  # #subscribe-block instead.

  Scenario: The footer shows its links, social icons and company details
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    Then the "footer" should be displayed
    And the "footer Bathroom Mirrors link" should be displayed
    And the "footer Contact Us link" should be displayed
    And the "footer Instagram link" should be displayed
    And the "footer YouTube link" should be displayed
    And the "footer company details" should contain the text "Company Registration No."
    And the "footer Sitemap link" should be displayed


  Scenario: A footer category link opens that category
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "footer Bathroom Mirrors link" element
    Then I should eventually be redirected to the "bathroom-mirrors" page
    And the "product card" should be displayed


  Scenario: A footer content link opens that page
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "footer Contact Us link" element
    Then I should eventually be redirected to the "contact-us" page
    And a heading with the text "Contact Us" should be displayed


  Scenario: "Stay Inspired" Subscribe opens the newsletter sign-up form (not submitted)
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Stay Inspired Subscribe" link
    Then the "newsletter signup iframe" should be displayed
    And the "newsletter signup email" inside the "newsletter signup iframe" iframe should be displayed
