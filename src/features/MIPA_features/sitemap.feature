@MIPA_regression
Feature: Sitemap

  # New coverage. /sitemap is itself a sitemap index (confirmed live: 5
  # sub-sitemap links - products, categories, content, articles,
  # article_categories) that also lists every individual product/category/
  # article URL inline on the same page (~2000 links total). Checking all
  # of them would be a slow, unnecessarily heavy crawl - the smoke test
  # itself only asks to "open sample product, page and article URLs", so
  # this samples a bounded few of each instead, plus the "page" sample
  # covered by an already-known real content page (brochures).
  #
  # Note found along the way: the category and article links on this page
  # are all `display: none` with no visible toggle to reveal them -
  # confirmed live, looks like a genuine rendering bug (not a deliberately
  # collapsed section). Not chased further here since it doesn't block
  # this check - a sitemap's own purpose is enumerating crawlable URLs for
  # search engines, which still index links present in the DOM regardless
  # of CSS visibility - but worth a look separately.

  Scenario: The sitemap index links all resolve
    Given I am on the "sitemap" page
    Then all "sitemap index links" links should resolve without an error


  Scenario: A sample of product, category and article URLs from the sitemap all resolve
    Given I am on the "sitemap" page
    Then the first 5 "sitemap product links" links should resolve without an error
    And the first 3 "sitemap category links" links should resolve without an error
    And the first 3 "sitemap article links" links should resolve without an error


  Scenario: A sample content page URL loads successfully
    Given I am on the "brochures" page
    Then the "header logo" should be displayed
