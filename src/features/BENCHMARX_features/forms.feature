@regression
Feature: Forms - contact, trade and contract enquiries, brochure and newsletter

  # BEN-379 (Next.js 15 upgrade) FRM-01 to FRM-04. Built 2026-11-11 from a
  # live inspection of staging. The contact, trade FAQ and contract kitchen
  # enquiry forms are the same Peracto form component (fields named
  # /form-fields/<id>) using native HTML5 validation: no inline error copy,
  # the browser blocks the submit. The newsletter is a native email field
  # too.
  #
  # REAL SUBMISSIONS (added 2026-11-12, agreed with the user): staging and
  # next-15 both post to the TEST Peracto admin (staging-api.benchmarx.pub
  # /form-submissions, 201), not to real branches. Every submission uses
  # explicit test data: name "Velstar Test", a disposable
  # qa-<timestamp>@velstar-test.co.uk email, and a message saying it's an
  # automated QA submission. Tagged @submits-real-form, so they never run
  # against production. On success the page redirects to a thank-you page
  # (the trade FAQ form shares the contact form's /contact-us/thank-you).
  # The newsletter posts a server action with the email (no redirect) and
  # swaps the form for "Thanks for subscribing".
  #
  # CONFIRMED 2026-11-12: on next-15 the newsletter server action fires but
  # the form never shows "Thanks for subscribing" (R9). The enquiry forms
  # work on both environments.
  #
  # Consultation booking is NOT covered here: it books real Acuity
  # calendars, so book-a-consultation.feature still stops before Confirm.

  # FRM-01
  Scenario: The contact form rejects an empty and an invalid submission
    Given I am on the "contact-us" page
    And I wait for the page to settle
    Then the "enquiry form" should be displayed
    When I click on the "form SUBMIT" button
    Then I should be redirected to the "contact-us" page
    And the "form Name" input should be rejected as empty
    And the "form Email address" input should be rejected as empty
    And the "form Telephone number" input should be rejected as empty
    And the "form Postcode" input should be rejected as empty
    And the "form Message" input should be rejected as empty
    When I fill in the "form Email address" input field with "not-an-email"
    And I click on the "form SUBMIT" button
    Then the "form Email address" input should be rejected as invalid

  # FRM-03
  Scenario Outline: The <form> enquiry form rejects an empty and an invalid submission
    Given I navigate directly to the path "<path>"
    And I wait for the page to settle
    Then the "enquiry form" should be displayed
    When I click on the "form SUBMIT" button
    Then the "form Name" input should be rejected as empty
    And the "form Email address" input should be rejected as empty
    And the "form Telephone number" input should be rejected as empty
    When I fill in the "form Email address" input field with "not-an-email"
    And I click on the "form SUBMIT" button
    Then the "form Email address" input should be rejected as invalid

    Examples:
      | form              | path                        |
      | trade FAQ         | /trade-customers/faqs       |
      | contract kitchens | /contract-kitchen-solutions |

  # FRM-02. "Order a copy" goes to a Google Form that answers "Page not
  # found" on staging too (pre-existing, not BEN-379), so only the "View
  # online" brochures (3dissue) are checked.
  Scenario: The brochure page's View online brochures open
    Given I am on the "request-a-brochure" page
    Then the "page heading" should contain the text "Request a brochure"
    And the "brochure links" should be displayed
    And all "brochure links" links should resolve without an error
    And the "first content image" image should return a 200 OK response with content-type "image/"

  # FRM-04
  Scenario: The newsletter sign-up rejects an empty and an invalid email
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as empty
    When I fill in the "newsletter email input" input field with "not-an-email"
    And I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as invalid

  # FRM-01, TRK-02 (submission side)
  @submits-real-form
  Scenario Outline: The <form> form submits with Velstar test data and shows its thank-you page
    Given I navigate directly to the path "<path>"
    And I wait for the page to settle
    When I fill in the "form Name" input field with "Velstar Test"
    And I fill in the "form Email address" input field with a unique email, remembering it as "test email"
    And I fill in the "form Telephone number" input field with "01234567890"
    And I fill in the "form Postcode" input field with "LS1 1AA" if present
    And I fill in the "form Message" input field with "Velstar Test - automated QA submission (BEN-379), please ignore."
    And I click on the "form SUBMIT" button
    Then the current URL should contain "<thank you path>"
    And the "content page" should contain the text "Thank you for your enquiry"

    Examples:
      | form              | path                        | thank you path                        |
      | contact           | /contact-us                 | /contact-us/thank-you                 |
      | trade FAQ         | /trade-customers/faqs       | /contact-us/thank-you                 |
      | contract kitchens | /contract-kitchen-solutions | /contract-kitchen-solutions/thank-you |

  # FRM-04
  @submits-real-form
  Scenario: The newsletter sign-up accepts a Velstar test email and confirms
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "newsletter email input" input field with a unique email, remembering it as "test email"
    And I click on the "newsletter submit button" button
    Then the "newsletter form" should contain the text "Thanks for subscribing"
