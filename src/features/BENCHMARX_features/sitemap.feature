@smoke @regression
Feature: Sitemaps

  # Qase BEN-116. Built 2026-10-24. There's no sitemap index file:
  # /sitemaps/sitemap.xml answers {"error":"Not Found"} on staging AND
  # production. Production's robots.txt lists the individual
  # /sitemaps/<type>.xml files instead, and staging serves the same set.
  # Each one is checked, then a sample of its URLs.

  Scenario Outline: The <sitemap> XML sitemap loads and its URLs resolve
    Given I am on the "home" page
    Then the first 5 URLs in the "/sitemaps/<sitemap>.xml" XML sitemap should resolve without an error

    Examples:
      | sitemap    |
      | products   |
      | categories |
      | content    |
      | articles   |
      | locations  |

  Scenario: The HTML sitemap page's links resolve
    Given I am on the "home" page
    When I click on the "footer sitemap link" link
    Then I should be redirected to the "sitemap" page
    And the first 20 "sitemap links" links should resolve without an error
