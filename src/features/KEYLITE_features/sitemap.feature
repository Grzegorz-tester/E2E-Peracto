@regression
Feature: Sitemap

  # Confirmed live 2026-09-06: /sitemap is a single flat page (container
  # "sitemaps") listing ~1500 links with no distinct product/category/
  # article sub-groupings like MIPA's sitemap has - so this samples a
  # bounded few of the page's own links rather than checking every one,
  # same reasoning as MIPA's sitemap.feature (a full crawl would be slow
  # and isn't what a smoke-level check needs).

  Scenario: A sample of sitemap links all resolve
    Given I am on the "sitemap" page
    Then the first 5 "sitemap links" links should resolve without an error
