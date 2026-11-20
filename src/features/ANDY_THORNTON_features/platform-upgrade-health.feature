@regression @not-on-production
Feature: Platform upgrade health (Next.js, Peracto, API)

  # Added 2026-11-19 for AT-201 (Next.js 16.4.3 / Node 24) and AT-185 (Peracto
  # 72 -> 79, Symfony 7.4, Doctrine 3.5, PHP 8.5). These catch what a framework
  # or API upgrade tends to break without any visible broken button: a missing
  # page served as 200 ("soft 404"), a protected page no longer redirecting,
  # a direct request to a core page failing, and a data call quietly 4xx/5xx-ing
  # while the page still renders. Ported from JTDove's version of this feature.
  #
  # Not run on production: prod rate-limits fast crawls (429 after ~10 quick
  # loads) and serves Cloudflare challenges to the runner (see NOTES.md).
  #
  # Baseline confirmed live on staging 2026-11-19 (before the upgrade lands):
  # real 404s for unknown page/category/article/article-category URLs, and
  # 307 /account -> /login?to=/account.


  Scenario Outline: A missing <kind> returns a real 404, not a soft 404
    Then requesting the path "<path>" should return status 404
    Examples:
      | kind             | path                                          |
      | page             | /velstar-no-such-page                         |
      | category         | /category/contract-furniture/velstar-no-such  |
      | article          | /article/velstar-no-such-article              |
      | article category | /articles/velstar-no-such-category            |


  # KNOWN SITE DEFECT, expected red (confirmed 2026-11-19 on staging AND
  # production, so it predates AT-201): an unknown product or branch URL
  # renders the "We couldn't find the page you're looking for" page but with
  # HTTP 200, so search engines index it as a real page. Kept in the suite so
  # a fix (or an upgrade that changes it) is visible.
  Scenario Outline: A missing <kind> returns a real 404 (known soft 404)
    Then requesting the path "<path>" should return status 404
    Examples:
      | kind    | path                               |
      | product | /products/velstar-no-such-product  |
      | branch  | /branches/velstar-no-such-branch   |


  Scenario Outline: The <page> page returns 200 to a direct request
    Then requesting the path "<path>" should return status 200
    Examples:
      | page              | path                                                   |
      | home              | /                                                      |
      | product           | /products/vienna-stackable-side-chair-atfuof1104       |
      | category          | /category/contract-furniture/dining-chairs             |
      | category page 2   | /category/contract-furniture/dining-chairs?page=2      |
      | search            | /search?q=chair                                        |
      | content           | /contract-furniture                                    |
      | article           | /article/keepers-kitchen-and-bar-oxford                |
      | branch            | /branches/warehouse                                    |


  Scenario Outline: A guest requesting <path> is redirected to the login page
    Then requesting the path "<path>" should return status 307
    Given I navigate directly to the path "<path>"
    Then I should eventually be redirected to the "login" page
    Examples:
      | path                |
      | /account            |
      | /account/quotes     |
      | /account/moodboards |


  # Every fetch/XHR to the storefront itself (Next.js server actions and RSC
  # payloads), the Peracto API (staging-api) and the asset host must succeed
  # while browsing the core pages. Third-party widgets (Tawk chat,
  # GetSiteControl, interactive-img, Loqate) are ignored.
  Scenario: Browsing the core shopping pages raises no failed API calls or page errors
    Given I start monitoring failed network responses from hosts matching "andythornton\.pub$"
    And I start monitoring console errors, ignoring messages matching "Failed to load resource|cookiebot|Cookiebot|google|gtm|facebook|hotjar|clarity|recaptcha|tawk|getsitecontrol|getsitectrl|interactive-img|postcodeanywhere|ERR_BLOCKED|ERR_FAILED"
    When I am on the "home" page
    And I wait for the page to settle
    And I am on the "dining-chairs" page
    And I wait for the page to settle
    And I am on the "pdp" page
    And I wait for the page to settle
    And I navigate directly to the path "/search?q=chair"
    And I wait for the page to settle
    And I navigate directly to the path "/article/keepers-kitchen-and-bar-oxford"
    And I wait for the page to settle
    And I am on the "basket" page
    And I wait for the page to settle
    Then there should be no failed network responses
    And there should be no unexpected console errors


  # AT-185's checklist names login and JWT refresh: a logged-in session must
  # survive a full reload and keep reaching protected account data.
  Scenario: A signed-in session survives reloads across the account pages
    Given I am navigating the page as a "non admin" user
    And I start monitoring failed network responses from hosts matching "andythornton\.pub$"
    When I am on the "account-orders" page
    And I reload the page
    And I wait for the page to settle
    Then I should be redirected to the "account-orders" page
    When I am on the "account-address-book" page
    And I reload the page
    And I wait for the page to settle
    Then I should be redirected to the "account-address-book" page
    And there should be no failed network responses
