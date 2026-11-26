@regression @HIB-179
Feature: Sitemaps

  # Added 2026-11-19 for HIB-179. The sitemaps are written to S3 by scheduled
  # Lambda tasks (sitemap_products, sitemap_content, ...), which the PHP 8.5 /
  # Bref v3 upgrade moves to a new runtime. robots.txt lists six sitemaps
  # under /sitemaps/ on every environment (confirmed live 2026-11-19).
  #
  # Confirmed live 2026-11-19:
  # - release-2-17-0 serves STAGING's sitemap files (same S3 object and
  #   version id, <loc>s point at staging.hib.pub), so the release's own
  #   sitemap tasks can't be observed from the release storefront.
  # - staging's sitemap tasks are all inactive (active: false, no schedule),
  #   so staging files only change when someone runs a task by hand.
  # - production's sitemap_products task is active but has NO schedule, so
  #   products.xml has not been regenerated since 17 March 2026, while
  #   product_images.xml (scheduled 02:35 daily) was written 2026-11-17.
  #
  # HIB serves missing pages as a 200 ("soft 404", see health-check.feature),
  # so the sampled-URL checks catch 5xx/timeouts, not stale entries.

  Scenario: robots.txt points at the sitemaps
    When I GET the site path "/robots.txt"
    Then the response status should be 200
    And the response body should contain "/sitemaps/products.xml"
    And the response body should contain "/sitemaps/content.xml"


  Scenario Outline: The <sitemap> sitemap is served
    When I GET the site path "/sitemaps/<sitemap>.xml"
    Then the response status should be 200
    And the response body should contain "<urlset"
    And the response body should contain "<loc>"
    Examples:
      | sitemap            |
      | products           |
      | product_images     |
      | content            |
      | categories         |
      | articles           |
      | article_categories |


  Scenario Outline: URLs in the <sitemap> sitemap resolve
    When I GET the site path "/sitemaps/<sitemap>.xml"
    Then 10 URLs sampled from the sitemap response should each return status 200
    Examples:
      | sitemap    |
      | content    |
      | categories |
      | products   |


  # Production only: that's the one environment where the tasks are meant to
  # run nightly. product_images is the canary that scheduled Lambdas still
  # fire after the runtime change. products is KNOWN RED (no schedule since
  # at least 17 March 2026, pre-existing, not caused by HIB-179); kept so a
  # fix is noticed.
  @production-only
  Scenario Outline: The <sitemap> sitemap was regenerated recently
    When I GET the site path "/sitemaps/<sitemap>.xml"
    Then the response status should be 200
    And the response should have been last modified within the last 3 days
    Examples:
      | sitemap        |
      | product_images |
      | products       |
