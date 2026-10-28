@smoke @regression
Feature: Book a design consultation

  # Qase BEN-121. Built 2026-10-24 from a live inspection of staging. A
  # four-step form: branch (nearest 3 to a typed town), consultation type,
  # date and time, then contact details with CONFIRM BOOKING ("One last
  # thing...").
  #
  # DELIBERATELY STOPS BEFORE CONFIRM BOOKING. Staging reads availability
  # from Acuity using the real branches' calendars (/api/acuity/...), so
  # confirming would book a real designer's slot and email the branch. Until
  # a test calendar or test branch exists, the scenario checks the button
  # is ready instead. This is also why BEN-122/123/124 (confirmation email,
  # cancel, reschedule) aren't automated: each starts from a real booking.
  #
  # The QA case's own example, Ashford, has NO bookable dates on staging:
  # Acuity answers {"message":"The calendar \"4707161\" does not belong to
  # appointment type \"23814535\"","error":"invalid_calendar"} for both
  # consultation types (confirmed 2026-10-24). Leeds and Croydon work, so
  # Leeds is used here. Only two consultation types are offered (Online,
  # In-branch), not the three the QA case describes.

  Scenario: Searching a town lists the three nearest branches
    Given I am on the "book-a-consultation" page
    And I wait for the page to settle
    When I fill in the "location input" input field with "Ashford"
    And I click on the "SHOW BRANCHES" button
    Then I should see "3" "branch options" displayed
    And the "1st" "branch options" should contain the text "Ashford"

  Scenario: A guest can fill in an in-branch booking up to Confirm Booking
    Given I am on the "book-a-consultation" page
    And I wait for the page to settle
    When I fill in the "location input" input field with "Leeds"
    And I click on the "SHOW BRANCHES" button
    Then I should see "3" "branch options" displayed
    When I click on the "first branch option" element
    And I click on the "NEXT" button
    Then the "step heading" should contain the text "What type of consultation would you like to book at the Leeds branch?"
    And the "Online consultation option" should be displayed
    And the "In-branch consultation option" should be displayed
    When I click on the "In-branch consultation option" element
    And I click on the "NEXT" button
    Then the "step heading" should contain the text "Choose a date and time"
    When I click on the first enabled "available dates" button
    Then the "first time slot" should be displayed
    When I click on the "first time slot" button
    And I click on the "NEXT" button
    Then the "step heading" should contain the text "One last thing..."
    When I fill in the "First Name" input field with "Velstar"
    And I fill in the "Last Name" input field with "Test"
    And I fill in the "Email" input field with a unique email, remembering it as "booking email"
    And I fill in the "Phone" input field with a unique UK mobile number, remembering it as "booking phone"
    Then the "booking summary" should contain the text "Leeds"
    And the "booking summary" should contain the text "In-branch design consultation"
    And the "CONFIRM BOOKING" should be displayed
    And the "CONFIRM BOOKING" should be enabled
