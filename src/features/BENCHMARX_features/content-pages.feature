@regression
Feature: Content pages - blog, articles, inspiration, trade, legal and campaign pages

  # BEN-379 (Next.js 15 upgrade) CNT-01 to CNT-07. Built 2026-11-11 from a
  # live inspection of staging. The blog paginates with ?page=N, which is
  # exactly the Next 15 risk (searchParams became asynchronous; see R1 on
  # search), so CNT-01 checks page 2 really shows different articles.
  #
  # Pre-existing on staging and live (not BEN-379): /privacy-notice is a 404.

  # CNT-01
  Scenario: The blog lists articles and its ?page=2 shows a different set
    Given I am on the "blog" page
    Then the "category heading" should contain the text "Blog"
    And I should see "12" "article cards" displayed
    When I remember the text of "first article card title" as "page 1 first article"
    And I navigate directly to the path "/articles/blog?page=2"
    Then I should see "12" "article cards" displayed
    And the "first article card title" text should not equal the remembered "page 1 first article"
    And the remembered "page 1 first article" should not appear in the "article card titles" element

  Scenario: Clicking the blog's page 2 link shows the next articles
    Given I am on the "blog" page
    And I wait for the page to settle
    When I remember the text of "first article card title" as "page 1 first article"
    And I click on the "page 2 link" link
    Then the current URL should contain "page=2"
    And the "first article card title" text should not equal the remembered "page 1 first article"

  Scenario: Each blog category chip opens its own article list
    Given I am on the "blog" page
    Then all "category chips" links should resolve without an error
    When I click on the "Appliances category" link
    Then I should be redirected to the "blog" page
    And the current URL should contain "/articles/appliances"
    And the "article cards" should be displayed

  # CNT-02. Only first-party (relative) links are requested. Older articles
  # hardcode absolute links to www.benchmarxkitchens.co.uk, several of which
  # 404 on live (e.g. /article/blog/introducing-our-new-benchmarx-design,
  # /kitchens/eton-serica-matt-taupe): a content issue, out of BEN-379
  # scope, noted in NOTES.md.
  # One article: every article is the same template (cut from five, plus
  # three for links, 2026-11-22).
  Scenario: An article renders with its images and its first-party links resolve
    Given I navigate directly to the path "/article/new-benchmarx-design-bude-range"
    And I wait for the page to settle
    Then the "page heading" should be displayed
    And the "article content" should be displayed within "30" seconds
    And the "first article image" should be displayed
    And the "first article image" image should return a 200 OK response with content-type "image/"
    And all "article links" links should resolve without an error

  Scenario: A blog card opens its article
    Given I am on the "blog" page
    When I remember the text of "first article card title" as "article title"
    And I click on the "first article card" link
    Then I should be redirected to the "article" page
    And the "page heading" should contain the remembered "article title"

  # CNT-03, CNT-04, CNT-05, CNT-06
  # One hub page and one child content page: the rest (finance, trade,
  # legal, about us...) are the same content template (cut from 14,
  # 2026-11-22). The contract kitchens and trade FAQ pages are also opened
  # by forms.feature.
  Scenario Outline: The <page> page renders fully
    Given I navigate directly to the path "<path>"
    Then the "page heading" should be displayed
    And the "content page" should be displayed
    And the "breadcrumb" should be displayed
    And requesting the path "<path>" should return status 200

    Examples:
      | page                         | path                                         |
      | ideas and inspiration        | /ideas-and-inspiration                       |
      | why choose us                | /help-advice/why-choose-us                   |

  # CNT-04: the trade landing page has no h1 on staging (nor does the
  # sign-in page, same template, dropped 2026-11-22).
  Scenario: The trade customers page renders fully
    Given I navigate directly to the path "/trade-customers"
    Then the "content page" should be displayed
    And the "breadcrumb" should be displayed
    And requesting the path "/trade-customers" should return status 200

  # CNT-06: the campaign page has no h1 on staging, so it's checked by title.
  Scenario: The Big Savings Event campaign page renders with its offers
    Given I am on the "big-savings-event" page
    Then the page title should contain "Big Savings Event"
    And the "content page" should be displayed
    And the "first content image" should be displayed
    And requesting the path "/big-savings-event" should return status 200

  # CNT-07
  Scenario: An unknown URL shows the branded 404 page with a 404 status and Next steps tiles
    Given I navigate directly to the path "/this-page-does-not-exist-ben-379"
    Then the "not found page" should be displayed
    And the "page heading" should contain the text "We couldn't find the page you're looking for"
    And the "next steps" should be displayed
    And the page title should contain "Not Found"
    And requesting the path "/this-page-does-not-exist-ben-379" should return status 404
