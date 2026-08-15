@regression
Feature: Sitemap redirects

  # Ported from P3Playwright's insinkerator_eu/tests/navigation/
  # sitemap-redirects.test.ts. The real sitemap categories are products,
  # categories, content, locations and product images. "locations" has
  # exactly one stale CMS entry - VERIFIED live (2026-08-15) this renders a
  # genuine HTTP 200 with a client-rendered "404 - We couldn't find the
  # page" state once the branch's own data fetch comes back empty, not a
  # server-level 404 - a documented, known site bug, not a redirect-
  # mechanism bug, so this is asserted via that rendered content rather
  # than response status.

  @smoke
  Scenario: User can navigate to the sitemap page from the footer
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    When I click on the "sitemap link" link
    Then I should be redirected to the "sitemap" page
    And the "sitemap heading" should equal text "Sitemap"

  Scenario Outline: Each sitemap category's first item redirects correctly
    Given I am on the "sitemap" page
    And I click on the "Select Portugal" button if present
    When I click on the "<category tab>" link
    And I click on the "sitemap category item" element and note the response status
    Then the noted response status should <comparison> <status>

    Examples:
      | category tab        | comparison     | status |
      | products tab        | be less than   | 400    |
      | categories tab      | be less than   | 400    |
      | content tab         | be less than   | 400    |
      | product images tab  | equal          | 200    |

  Scenario: "locations" category's first item currently shows a not-found state (known site bug)
    Given I am on the "sitemap" page
    And I click on the "Select Portugal" button if present
    When I click on the "locations tab" link
    And I click on the "sitemap category item" element
    Then a heading with the text "404" should be displayed
