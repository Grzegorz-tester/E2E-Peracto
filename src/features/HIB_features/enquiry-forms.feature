@regression
Feature: Contact Us and Customer Feedback

  # Built 2026-09-29 from a live inspection of feature-hib-170 and production.
  #
  # NEVER click the feedback form's Submit, on any environment: form 10 has
  # sendAdminEmail: true, so a submission emails real HIB staff. On the
  # release branch it is worse - the form currently has no fields at all
  # (see below), so there is nothing to validate and a click would send a
  # real, empty submission. These scenarios only check the page renders.
  #
  # Contact Us has no form: it is phone/email links plus a Google Maps embed.
  #
  # KNOWN RED on feature-hib-170 (2026-09-29): the Customer Feedback form
  # renders only its Submit button. Confirmed via the API - GET /forms/10
  # returns 0 formFieldLinks on hib-170-api.hib.pub vs 9 on api.hib.co.uk.
  # 7 of those 9 fields exist on the release backend but aren't linked to
  # the form, and 2 newer ones (120, 124) don't exist there at all - release
  # data drift, not a code bug and not caused by this suite.

  Scenario: Contact Us shows the phone number, email addresses and location map
    Given I am on the "contact-us" page
    And I dismiss the newsletter popup if present
    Then a heading with the text "Contact Us" should be displayed
    And the "phone link" should be displayed
    And the "sales email link" should be displayed
    And the "product support email link" should be displayed
    And the "location map" should be displayed


  Scenario: The Customer Feedback form renders its questions (not submitted)
    Given I am on the "customer-feedback-form" page
    And I dismiss the newsletter popup if present
    Then a heading with the text "Customer Feedback Form" should be displayed
    And the "relationship question" should be displayed
    And the "recommend question" should be displayed
    And the "additional comments question" should be displayed
    And the "feedback dropdowns" should be displayed
    And the "feedback text areas" should be displayed
    And the "feedback Submit" should be displayed
