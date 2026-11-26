@regression
Feature: SEO output and HTTP status codes

  # BEN-379 (Next.js 15 upgrade) SEO-01, SEO-02, SEO-03, SEO-05. Built
  # 2026-11-11 from a live inspection of staging. Next 15 changed how
  # metadata and not-found pages are generated, so every template's head is
  # checked: a title in the "<page> | Benchmarx Kitchens & Joinery" pattern
  # (the booking page's title is just "Benchmarx Kitchens & Joinery" on
  # staging, so it only gets the brand check),
  # a meta description, a canonical pointing at the page itself on the host
  # under test, og:title and parseable JSON-LD.
  #
  # CONFIRMED 2026-11-11: next-15 returns HTTP 200 for /kitchens/does-not-exist
  # (staging: 404). A soft 404 gets indexed by search engines.
  #
  # Staging's robots.txt is "Disallow: /" (correct for a non-production
  # host), so SEO-03 checks it isn't accidentally opened up on the feature
  # branch. Sitemap content is covered by sitemap.feature.

  # SEO-01, SEO-02
  Scenario Outline: The <page> template has a complete, self-referencing head
    Given I navigate directly to the path "<path>"
    Then the page title should contain "Benchmarx Kitchens & Joinery"
    And the page title should contain "<title>"
    And the "meta description" head tag should have a non-empty "content"
    And the "canonical link" head tag's "href" should match the current URL path
    And the "og title" head tag should have a non-empty "content"
    And the "json-ld" head tag should have a non-empty "text"
    And every JSON-LD block on the page should be valid JSON

    Examples:
      | page              | path                                     | title                         |
      | home              | /                                        | Home                          |
      | all kitchens      | /kitchen-ranges/all-kitchens             | All kitchens                  |
      | pdp               | /kitchens/nordica-blue-true-handleless   | Nordica Blue True Handleless  |
      | branch            | /branches/leeds                          | Leeds                         |
      | branch finder     | /branches                                | Branches                      |
      | contact           | /contact-us                              | Contact us                    |
      | brochure          | /request-a-brochure                      | Request a Brochure            |
      | blog              | /articles/blog                           | Blog                          |
      | article           | /article/new-benchmarx-design-bude-range | NEW Benchmarx Bude Range      |
      | accessories       | /accessories-and-appliances              | Accessories and appliances    |
      | booking           | /book-a-consultation                     | Benchmarx                     |
      | customer kitchens | /customer-kitchens                       | Customer                      |

  # SEO-05
  Scenario Outline: <case> returns HTTP <status>
    Given I am on the "home" page
    Then requesting the path "<path>" should return status <status>

    Examples:
      | case                     | path                                   | status |
      | The homepage             | /                                      | 200    |
      | A kitchen listing        | /kitchen-ranges/all-kitchens           | 200    |
      | A PDP                    | /kitchens/nordica-blue-true-handleless | 200    |
      | A branch page            | /branches/leeds                        | 200    |
      | A blog page 2            | /articles/blog?page=2                  | 200    |
      | A search                 | /search?q=oak                          | 200    |
      | An unknown article       | /article/does-not-exist-ben-379        | 404    |
      | An unknown kitchen range | /kitchen-ranges/does-not-exist-ben-379 | 404    |

  # SEO-01: the 404 page is noindex.
  Scenario: The 404 page is marked noindex
    Given I navigate directly to the path "/kitchens/does-not-exist"
    Then the "robots meta" should have attribute "content" containing "noindex"

  # SEO-03
  Scenario: robots.txt is served and keeps the non-production host out of search
    Given I am on the "home" page
    Then requesting the path "/robots.txt" should return status 200
    And the response body of the path "/robots.txt" should contain "Disallow: /"
