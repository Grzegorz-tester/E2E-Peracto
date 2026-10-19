@regression
Feature: Contact Us page

  # Real route is "/contact", not "/contact-us" - confirmed live 2026-09-06.
  # Like MIPA's contact-us.feature, this only checks the form renders rather
  # than submitting it - Keylite's fields have no data-testid (only raw
  # form-field name attributes), and submission behaviour/success state
  # wasn't confirmed live, so this stays a presence check for now.

  Scenario: Contact form fields are present
    Given I am on the "contact" page
    And I dismiss the newsletter popup if present
    Then the "First Name" should be displayed
    And the "Last Name" should be displayed
    And the "Contact Number" should be displayed
    And the "Email" should be displayed
    And the "Message" should be displayed
    And the "Submit Query" should be displayed

  # An empty submit is blocked client-side (native "required"), so this
  # sends nothing.
  Scenario: Submitting the contact form empty is blocked before anything is sent
    Given I am on the "contact" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I click on the "Submit Query" button
    Then the "First Name" input should be rejected as empty
    And I should be redirected to the "contact" page

  # A REAL submission, agreed 2026-09-24: the "Contact Query" form (Peracto
  # Admin > Forms, id 13) emails Keylite's own staff inboxes even on
  # staging, so the test data says clearly what it is ("Velstar Test", a
  # disposable address, a "please ignore" message). Consent is left
  # unticked on purpose - it isn't required, and a test identity shouldn't
  # opt in to anything. @submits-real-form keeps it off production.
  # CONFIRMED live: POST /form-submissions -> 201, then a redirect to
  # /thank-you; reCAPTCHA (v3, invisible) doesn't block the headless run.
  # "Subject" is a Radix combobox over a hidden <select> (Customer Care /
  # Technical Support / Sales Support / Generic Enquiry / Media Enquiry).
  @submits-real-form
  Scenario: Submitting the contact form with valid details reaches the thank-you page
    Given I am on the "contact" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I fill in the "First Name" input field with "Velstar"
    And I fill in the "Last Name" input field with "Test"
    And I fill in the "Contact Number" input field with "07911123456"
    And I fill in the "Email" input field with a unique email, remembering it as "contact email"
    And I select the "Generic Enquiry" option from the "Subject" listbox
    And I fill in the "Message" input field with "Velstar Test - automated QA submission from the E2E regression suite. Please ignore."
    And I click on the "Submit Query" button
    Then I should eventually be redirected to the "thank-you" page
    And the "thank you message" should contain the text "Thank you for submitting a form!"
