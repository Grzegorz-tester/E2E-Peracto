@regression
Feature: Role-based access control

  # ISE-SP.11, .12, .16 and .18. The SoW requires Settings to be Owner-only
  # "even via a direct URL", and Service Engineers to only ever see their
  # own company's jobs. Both checks are done by direct URL, not just by the
  # menu being hidden.
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
    And the "Engineers menu link" should <admin pages> be displayed
    And the "Companies menu link" should <admin pages> be displayed
    And the "Fault codes menu link" should <admin pages> be displayed
    And the "Users menu link" should <admin pages> be displayed
    And the "Tasks menu link" should <admin pages> be displayed
    And the "Settings menu link" should <settings> be displayed

    Examples:
      | user     | admin pages | settings |
      | owner    |             |          |
      | admin    |             | not      |
      | engineer | not         | not      |

  @smoke
  Scenario Outline: Settings is Owner-only, even by direct URL, for "<user>"
    Given I am navigating the page as a "<user>" user
    When I navigate directly to the path "/settings"
    Then the "page title" should contain the text "Access Denied"

    Examples:
      | user     |
      | admin    |
      | engineer |

  Scenario: The Owner can open Settings
    Given I am navigating the page as a "owner" user
    When I navigate directly to the path "/settings"
    Then I should be redirected to the "settings" page
    And a heading with the text "Settings" should be displayed

  Scenario Outline: A Service Engineer is denied the "<path>" admin page by direct URL
    Given I am navigating the page as a "engineer" user
    When I navigate directly to the path "<path>"
    Then the "page title" should contain the text "Access Denied"

    Examples:
      | path         |
      | /users       |
      | /companies   |
      | /engineers   |
      | /fault-codes |
      | /admin/tasks |

  Scenario: A Service Engineer cannot open a job that isn't theirs by direct URL
    # Admin opens a job to get a real job URL, then the Engineer (Test
    # Company) tries the same URL. It uses the first Complete job, not the
    # first job overall: this suite's own job journeys create Test Company
    # jobs that float to the top of the dashboard (which the engineer can
    # legitimately open), but never complete them.
    Given I am navigating the page as a "admin" user
    When I navigate directly to the path "/?filter=complete"
    And I click on the "first job card" element
    Then I should be redirected to the "job-detail" page
    And I remember the current URL path as "other company job"
    When I navigate directly to the path "/logout"
    And I am navigating the page as a "engineer" user
    And I navigate directly to the remembered path "other company job"
    Then the "page title" should contain the text "Access Denied"
