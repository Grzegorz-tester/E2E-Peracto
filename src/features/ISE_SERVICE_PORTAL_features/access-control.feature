@regression
Feature: Role-based access control

  # ISE-SP.11, .12, .16 and .18. The SoW requires Settings to be Owner-only
  # "even via a direct URL", and Service Engineers to only ever see their
  # own company's jobs. Both checks are done by direct URL, not just by the
  # menu being hidden.
  #
  # Roles as built (CONFIRMED live, 2026-10-06): Owner, Admin, Service
  # Manager (company-level: its company's jobs and engineers), Service
  # Engineer (its company's jobs only) and Developer (dashboard and My files
  # only - can't even start a job). The Manager and Engineer test accounts
  # belong to "Test Company".
  #
  # CONFIRMED live (2026-10-06): Admin can open Users and Tasks (manual
  # product sync / Aquatherm export). The SoW puts user management and the
  # manual sync/export controls inside the Owner-only Settings area - the
  # built app splits them out to their own pages, and this suite asserts
  # what's built. Flagged as an open question, not treated as a bug.

  Scenario Outline: The "<user>" menu shows exactly what that role should see
    Given I am navigating the page as a "<user>" user
    When I click on the "Menu" element
    Then the "Dashboard menu link" should be displayed
    And the "My files menu link" should be displayed
    And the "Engineers menu link" should <engineers> be displayed
    And the "Companies menu link" should <admin pages> be displayed
    And the "Fault codes menu link" should <admin pages> be displayed
    And the "Users menu link" should <admin pages> be displayed
    And the "Tasks menu link" should <admin pages> be displayed
    And the "Settings menu link" should <settings> be displayed

    Examples:
      | user      | engineers | admin pages | settings |
      | owner     |           |             |          |
      | admin     |           |             | not      |
      | manager   |           | not         | not      |
      | engineer  | not       | not         | not      |
      | developer | not       | not         | not      |

  @smoke
  Scenario Outline: Settings is Owner-only, even by direct URL, for "<user>"
    Given I am navigating the page as a "<user>" user
    When I navigate directly to the path "/settings"
    Then the "page title" should contain the text "Access Denied"

    Examples:
      | user      |
      | admin     |
      | manager   |
      | engineer  |
      | developer |

  Scenario: The Owner can open Settings
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/settings"
    Then I should be redirected to the "settings" page
    And a heading with the text "Settings" should be displayed

  Scenario Outline: A "<user>" user is denied the "<path>" page by direct URL
    Given I am navigating the page as a "<user>" user
    When I navigate directly to the path "<path>"
    Then the "page title" should contain the text "Access Denied"

    Examples:
      | user      | path         |
      | engineer  | /users       |
      | engineer  | /companies   |
      | engineer  | /engineers   |
      | engineer  | /fault-codes |
      | engineer  | /admin/tasks |
      | manager   | /users       |
      | manager   | /companies   |
      | manager   | /fault-codes |
      | manager   | /admin/tasks |
      | developer | /users       |
      | developer | /companies   |
      | developer | /engineers   |
      | developer | /fault-codes |
      | developer | /admin/tasks |
      | developer | /job/new     |

  Scenario: A Service Manager can only add engineers to their own company
    # /engineers/new/<company id>: Test Company is 1, any other id is
    # another company.
    Given I am navigating the page as a "manager" user
    When I navigate directly to the path "/engineers/new/2"
    Then the "page title" should contain the text "Access Denied"

  Scenario Outline: A "<user>" user cannot open another company's job by direct URL
    # The Owner creates a job for a different company (Carter Building
    # Services) so the URL is guaranteed not to belong to Test Company -
    # borrowing an existing dashboard job broke twice, as this suite's own
    # Test Company jobs float to the top of every list.
    # CONFIRMED live (2026-10-06): the Engineer gets 403 "Access Denied", the
    # Manager gets 404 "Page Not Found" for the same job - both deny access.
    Given I am navigating the page as a "owner" user
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page
    When I select the "Carter Building Services" option from the "Service company" dropdown
    And I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with "1 Velstar Test Street"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Next" button
    And I fill in the "PO number" input field with a unique code
    And I click on the "Installation option" element
    And I click on the "Inside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    And I remember the current URL path as "other company job"
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "<user>" user
    And I navigate directly to the remembered path "other company job"
    Then the "page title" should contain the text "<denied>"

    Examples:
      | user      | denied        |
      | engineer  | Access Denied |
      | manager   | Not Found     |
      | developer | Access Denied |

  Scenario Outline: A "<user>" user doesn't see another company's jobs on the dashboard
    # SP.11 / SP.12: the company filter is fixed, so even an exact search
    # for another company's job reference finds nothing.
    Given I am navigating the page as a "owner" user
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page
    When I select the "Carter Building Services" option from the "Service company" dropdown
    And I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Email" input field with "grzegorz.hajduk+ise-sp-customer@velstar.co.uk"
    And I click on the "Enter manually" button
    And I fill in the "Address line 1" input field with "1 Velstar Test Street"
    And I fill in the "Town" input field with "Leeds"
    And I fill in the "Postcode" input field with "LS1 1AA"
    And I click on the "Next" button
    And I fill in the "PO number" input field with a unique code
    And I click on the "Installation option" element
    And I click on the "Inside radius option" element
    And I click on the "Create job" button
    Then I should be redirected to the "job-detail" page
    And I remember the part of the "job heading" text matching the pattern "(JOB-[0-9A-F]+)" as "job reference"
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "<user>" user
    And I fill in the "Search jobs" input field with the remembered "job reference"
    And I press Enter in the "Search jobs" input field
    Then the current URL should contain "q="
    And the "no jobs message" should be displayed

    Examples:
      | user     |
      | engineer |
      | manager  |

