@regression @creates-users
Feature: Engineer management

  # ISE-SP.13 / SP.14: a service company manages its own engineers - add,
  # and hide (never delete, so historic jobs keep who did the work). As
  # built (CONFIRMED live, 2026-10-07), the Service Manager does this from
  # Engineers (/engineers), scoped to its own company: "New engineer" goes
  # to /engineers/new/<company id>, and another company's id is 403
  # (covered in access-control.feature). Owner and Admin see every
  # company's engineers.
  #
  # CONFIRMED live: the "+ Engineer" button on the Manager's Engineers page
  # does nothing (a submit button outside any form). The working entry
  # point is the separate "New engineer" link.

  Background:
    Given I am navigating the page as a "manager" user
    When I navigate directly to the path "/engineers"

  @smoke
  Scenario: A Service Manager adds an engineer to their company
    When I click on the "New engineer" link
    Then I should be redirected to the "engineer-new" page
    When I fill in the "Email" input field with a unique email, remembering it as "engineer email"
    And I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test Engineer"
    And I click on the "Add engineer" button
    Then I should eventually be redirected to the "engineers" page
    When I fill in the "Search engineers" input field with the remembered "engineer email"
    And I press Enter in the "Search engineers" input field
    Then the "first engineer" should contain the text "Velstar Test Engineer"
    And the "first engineer" should contain the text "Test Company"

  Scenario: The Service Manager only sees their own company's engineers
    Then the "engineer list" should contain the text "Test Company"
    And the "engineer list" should not contain the text "Carter Building Services"
    And the "engineer list" should not contain the text "Reid Mechanical Services"

  Scenario: The "+ Engineer" button opens the add-engineer form
    # CONFIRMED live (2026-10-07): currently FAILS - the button is a submit
    # button outside any form, so clicking it does nothing. Left red.
    When I click precisely on the "+ Engineer button" button
    Then I should be redirected to the "engineer-new" page

  Scenario: A hidden engineer is no longer offered when assigning a job
    # SP.13/14: hide, don't delete. Unlike the Users page, the engineer
    # Active/Inactive form here works (CONFIRMED live, 2026-10-07).
    When I click on the "New engineer" link
    Then I should be redirected to the "engineer-new" page
    When I fill in the "Email" input field with a unique email, remembering it as "engineer email"
    And I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Hidden Engineer"
    And I click on the "Add engineer" button
    Then I should eventually be redirected to the "engineers" page
    When I fill in the "Search engineers" input field with the remembered "engineer email"
    And I press Enter in the "Search engineers" input field
    Then the "first engineer" should contain the text "Velstar Hidden Engineer"
    When I click on the "first engineer" link
    Then I should be redirected to the "engineer-detail" page
    When I click precisely on the "Inactive button" button
    Then the "current status" should contain the text "Inactive"
    When I navigate directly to the path "/engineers?filter=inactive"
    And I fill in the "Search engineers" input field with the remembered "engineer email"
    And I press Enter in the "Search engineers" input field
    Then the "first engineer" should contain the text "Velstar Hidden Engineer"
    When I navigate directly to the path "/"
    And I click on the "first job card" element
    Then I should be redirected to the "job-detail" page
    When I click precisely on the "Change engineer" link
    Then I should be redirected to the "job-assign" page
    And the "Assigned engineer" should not contain the text "Velstar Hidden Engineer"
    And the "Assigned engineer" should contain the text "Grzegorz Hajduk"
