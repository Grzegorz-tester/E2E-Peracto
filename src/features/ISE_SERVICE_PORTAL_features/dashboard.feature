@regression
Feature: Dashboard job list

  # ISE-SP.10: every job with its status, searchable by customer name,
  # email or postcode, filter chips for status and Service Type, a New job
  # button and pagination. Runs as Admin (sees every company's jobs) so
  # there's always data to search and filter.
  #
  # Search scenarios wait for "q=" in the URL before asserting: the
  # remembered customer is usually already first on the unfiltered list, so
  # asserting before the results load passes falsely. CONFIRMED live
  # (2026-10-06): exactly that made the email search pass even though it
  # returns nothing for every job.

  Background:
    Given I am navigating the page as a "admin" user

  @smoke
  Scenario: The dashboard lists jobs with a New job button and pagination
    Then the "New job" should be displayed
    And the "first job card" should be displayed
    And the "pagination" should contain the text "Page 1 of"

  Scenario: The New job button opens the job form
    When I click on the "New job" link
    Then I should be redirected to the "job-new" page

  Scenario: Pagination moves to the next page of jobs
    When I click on the "Next page" link
    Then the current URL should contain "page=2"
    And the "pagination" should contain the text "Page 2 of"
    And the "first job card" should be displayed

  Scenario Outline: Filtering by "<filter>" only shows matching jobs
    When I click on the "<filter> filter" link
    Then the "active filter" should equal text "<filter>"
    And the "job card status" should all contain the text "<status>"

    Examples:
      | filter                 | status                 |
      | Complete               | Complete               |
      | Awaiting authorisation | Awaiting authorisation |

  Scenario Outline: The "<filter>" Service Type filter can be applied
    # Job cards don't show the Service Type, so this checks the filter is
    # applied and returns jobs, not each card's type.
    When I click on the "<filter> filter" link
    Then the "active filter" should equal text "<filter>"
    And the current URL should contain "filter=<param>"
    And the "first job card" should be displayed

    Examples:
      | filter       | param        |
      | Warranty     | warranty     |
      | Installation | installation |

  Scenario: Searching by customer name finds that customer's jobs
    When I remember the text of "first job card name" as "customer name"
    And I fill in the "Search jobs" input field with the remembered "customer name"
    And I press Enter in the "Search jobs" input field
    Then the current URL should contain "q="
    And the "first job card name" should contain the remembered "customer name"

  Scenario: Searching by job reference finds that job
    # CONFIRMED live (2026-10-06): the reference exactly as the card shows
    # it ("#JOB-E2EF3063") returns no results, while "JOB-E2EF3063" and
    # "E2EF3063" both work. Not a SoW requirement, so this searches without
    # the "#"; flagged separately as a usability issue.
    When I remember the text of "first job card reference" with the prefix "#" stripped, as "job reference"
    And I fill in the "Search jobs" input field with the remembered "job reference"
    And I press Enter in the "Search jobs" input field
    Then the current URL should contain "q="
    And the "first job card reference" should contain the remembered "job reference"

  Scenario: Searching by postcode finds that customer's job
    When I remember the text of "first job card name" as "customer name"
    And I click on the "first job card" element
    And I should be redirected to the "job-detail" page
    And I remember the part of the "customer address" text matching the pattern "([A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})$" as "postcode"
    And I click on the "Back to dashboard" link
    And I should be redirected to the "dashboard" page
    And I fill in the "Search jobs" input field with the remembered "postcode"
    And I press Enter in the "Search jobs" input field
    Then the current URL should contain "q="
    And the "first job card name" should contain the remembered "customer name"

  Scenario: Searching by customer email finds that customer's job
    # CONFIRMED live (2026-10-06): currently FAILS - an exact customer
    # email (and any part of one) returns "No jobs to show.", while name,
    # job reference and postcode all work. The SoW (ISE-SP.10) lists email
    # as a search field; the search placeholder only says "name, number
    # postcode". Left red deliberately until it's confirmed whether email
    # search was descoped or is a defect.
    When I remember the text of "first job card name" as "customer name"
    And I click on the "first job card" element
    And I should be redirected to the "job-detail" page
    And I remember the text of "customer email" as "customer email"
    And I click on the "Back to dashboard" link
    And I should be redirected to the "dashboard" page
    And I fill in the "Search jobs" input field with the remembered "customer email"
    And I press Enter in the "Search jobs" input field
    Then the current URL should contain "q="
    And the "first job card name" should contain the remembered "customer name"

  Scenario: A search with no matches shows the empty state
    When I fill in the "Search jobs" input field with "velstar-test-no-such-job"
    And I press Enter in the "Search jobs" input field
    Then the current URL should contain "q="
    And the "no jobs message" should be displayed
