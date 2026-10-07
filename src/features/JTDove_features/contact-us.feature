@regression
Feature: Contact and appointment forms

  # New coverage (2026-10-05). Neither form is ever submitted: both send to
  # real JT Dove staff (same reasoning as Keylite's and MIPA's forms), so
  # these scenarios only check the forms render and hold back incomplete
  # input via the browser's own required-field validation.

  Scenario: Contact page shows phone numbers, email and the enquiry form
    Given I am on the "contact-us" page
    And I wait for the page to settle
    Then the "page heading" should contain the text "Contact Us"
    And the "phone numbers" should be displayed
    And the "web support email" should be displayed
    And the "Name" should be displayed
    And the "Email Address" should be displayed
    And the "Mobile Phone" should be displayed
    And the "Message" should be displayed
    And the "Submit" should be displayed


  Scenario: Contact form won't submit without the required fields
    Given I am on the "contact-us" page
    And I wait for the page to settle
    When I click on the "Submit" button
    Then the "Name" input should be rejected as empty
    And I should be redirected to the "contact-us" page


  Scenario: Contact form rejects an invalid email address
    Given I am on the "contact-us" page
    And I wait for the page to settle
    When I fill in the "Name" input field with "Velstar Test"
    And I fill in the "Email Address" input field with "not_an_email@"
    And I click on the "Submit" button
    Then the "Email Address" input should be rejected as invalid


  Scenario: Contact page "Branch Finder" link opens the branch finder
    Given I am on the "contact-us" page
    And I wait for the page to settle
    When I click on the "Branch Finder link" element, retrying until redirected to the "branches" page


  Scenario Outline: The <form> appointment form renders its required fields
    Given I am on the "<page>" page
    And I wait for the page to settle
    Then the "page heading" should contain the text "design appointment"
    And the "Name" should be displayed
    And the "Contact Number" should be displayed
    And the "Email Address" should be displayed
    And the "Address Line 1" should be displayed
    And the "Postcode" should be displayed
    And the "Preferred Date" should be displayed
    And the "Submit" should be displayed
    Examples:
      | form     | page                 |
      | bathroom | bathroom-appointment |
      | kitchen  | kitchen-appointment  |


  Scenario: Appointment form won't submit without the required fields
    Given I am on the "bathroom-appointment" page
    And I wait for the page to settle
    When I click on the "Submit" button
    Then the "Name" input should be rejected as empty
    And I should be redirected to the "bathroom-appointment" page


  Scenario: FAQ answers open when their question is clicked
    Given I am on the "faqs" page
    And I wait for the page to settle
    Then the "page heading" should contain the text "FAQs"
    When I click on the "first FAQ question" element
    Then the "open FAQ answer" should be displayed
