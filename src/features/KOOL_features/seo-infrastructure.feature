@smoke
@regression
Feature: SEO & Infrastructure

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > SEO &
  # Infrastructure" (case 547). Confirmed live: /sitemap renders a page
  # with thousands of links, including product URLs. Its internal
  # structure (tabs/categories, like Insinkerator_EU's sitemap) hasn't
  # been explored - this checks the first product link only.

  # 2026-09-28: the "sitemap" page id now opens /sitemap/products - the
  # sitemap is tabbed (Shop/Products/Content/...) with Shop as the default,
  # and product links only render on the Products tab (confirmed identical
  # on staging and release-2-19-0).
  Scenario: Sitemap - URLs are accessible and linked pages load
    Given I am on the "sitemap" page
    And I click on the "Accept cookies" button if present
    Then the "sitemap heading" should be displayed
    When I click on the "first sitemap product link" element and note the response status
    Then the noted response status should be less than 400
