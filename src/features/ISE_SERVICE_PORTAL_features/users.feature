@regression @creates-users
Feature: User management

  # ISE-SP.16 / SP.18 user management. As built (CONFIRMED live,
  # 2026-10-07) this is the Users page (/users), open to Owner and Admin
  # (the SoW puts it inside the Owner-only Settings area). New users get no
  # email: the confirmation says to use "Forgot password" to set a
  # password. "Inactive" disables the account; "Delete" is a soft delete
  # with a Restore option under the Deleted filter.
  #
  # CONFIRMED DEFECT (live, 2026-10-07): the Active / Inactive / Delete
  # buttons on the Users page silently do nothing for a real user. Root
  # cause, traced via request logging: the login form (and other forms such
  # as Add user) submit through the page's JavaScript CSRF controller, which
  # sends a "csrf-token" header. Once a session has done that, Symfony's
  # same-origin CSRF check expects it on every later form - but the Users
  # row-action forms don't use that controller, so their POST is rejected
  # with a bare 302 back to /users (no message, no change). It only appeared
  # to work in quick exploration scripts that submitted the login form
  # before its JavaScript had loaded. The disable and delete scenarios below
  # are left red deliberately until this is fixed.
  #
  # The app uses Turbo: after a search the URL changes before the list
  # re-renders, so every search waits for the expected email to appear in
  # the first record before clicking anything in it.
  #
  # Test users are qa-<timestamp>@velstar-test.co.uk; one is added per run.

  Background:
    Given I am navigating the page as a "owner" user

  @smoke
  Scenario: The Owner adds a Service Engineer to a company
    When I navigate directly to the path "/users"
    And I click on the "New user" link
    Then I should be redirected to the "user-new" page
    When I fill in the "Email" input field with a unique email, remembering it as "user email"
    And I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I click on the "Service Engineer role" element
    And I select the "Test Company" option from the "Company" dropdown
    And I click on the "Save user" button
    Then I should be redirected to the "users" page
    And the "flash message" should contain the text "User Velstar Test added."
    And the "flash message" should contain the text "Forgot password"
    When I fill in the "Search users" input field with the remembered "user email"
    And I press Enter in the "Search users" input field
    Then the "first record" should contain the remembered "user email"
    And the "first record title" should contain the text "Velstar Test"
    And the "first record roles" should equal text "Service Engineer"
    And the "first record company" should equal text "Test Company"
    And the "first record badge" should equal text "Enabled"

  Scenario: The Owner disables and re-enables a user
    # Currently FAILS on the defect above.
    When I navigate directly to the path "/users?filter=active&role=all&q=velstar-test.co.uk"
    And I remember the part of the "first record" text matching the pattern "(qa-\d+@velstar-test\.co\.uk)" as "user email"
    And I click precisely on the "first record Inactive button" button
    Then the "flash message" should contain the text "disabled."
    When I navigate directly to the path "/users?filter=inactive&role=all"
    And I fill in the "Search users" input field with the remembered "user email"
    And I press Enter in the "Search users" input field
    Then the "first record" should contain the remembered "user email"
    And the "first record badge" should equal text "Disabled"
    When I click precisely on the "first record Active button" button
    Then the "flash message" should contain the text "enabled"
    When I navigate directly to the path "/users?filter=active&role=all"
    And I fill in the "Search users" input field with the remembered "user email"
    And I press Enter in the "Search users" input field
    Then the "first record" should contain the remembered "user email"
    And the "first record badge" should equal text "Enabled"

  Scenario: The Owner deletes a user and restores them
    # Currently FAILS on the defect above.
    When I navigate directly to the path "/users?filter=active&role=all&q=velstar-test.co.uk"
    And I remember the part of the "first record" text matching the pattern "(qa-\d+@velstar-test\.co\.uk)" as "user email"
    And I click precisely on the "first record Delete button" button
    Then the "flash message" should contain the text "deleted."
    When I navigate directly to the path "/users?filter=deleted&role=all"
    And I fill in the "Search users" input field with the remembered "user email"
    And I press Enter in the "Search users" input field
    Then the "first record" should contain the remembered "user email"
    When I click precisely on the "first record Restore button" button
    Then the "flash message" should contain the text "restored"
    When I navigate directly to the path "/users?filter=active&role=all"
    And I fill in the "Search users" input field with the remembered "user email"
    And I press Enter in the "Search users" input field
    Then the "first record" should contain the remembered "user email"

  Scenario: The Owner edits a user's name
    When I navigate directly to the path "/users?filter=active&role=all&q=velstar-test.co.uk"
    And I remember the part of the "first record" text matching the pattern "(qa-\d+@velstar-test\.co\.uk)" as "user email"
    And I click on the "first record Edit" link
    Then I should be redirected to the "user-edit" page
    When I fill in the "Last name" input field with "Test Edited"
    And I click on the "Save user" button
    Then I should be redirected to the "users" page
    When I fill in the "Search users" input field with the remembered "user email"
    And I press Enter in the "Search users" input field
    Then the "first record" should contain the remembered "user email"
    And the "first record title" should contain the text "Velstar Test Edited"

  Scenario: Adding a user without an email is rejected
    When I navigate directly to the path "/users/new"
    And I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I click on the "Save user" button
    Then the "Email input" input should be rejected as empty
    And I should be redirected to the "user-new" page

  Scenario Outline: The "<filter>" role filter only lists "<role>" users
    When I navigate directly to the path "/users"
    And I click on the "<filter> filter" link
    Then the current URL should contain "role=<param>"
    And the "record roles" should all contain the text "<role>"

    Examples:
      | filter    | param    | role             |
      | Admins    | admin    | Admin            |
      | Managers  | manager  | Service Manager  |
      | Engineers | engineer | Service Engineer |
