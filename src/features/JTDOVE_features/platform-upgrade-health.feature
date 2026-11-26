@regression
Feature: Platform upgrade health (Next.js, Peracto, API)

  # Added 2026-11-18 for the Peracto/API/Next.js upgrade tickets. These catch
  # the failures a framework or API upgrade tends to cause without any visible
  # broken button: a missing page served as 200 ("soft 404"), a protected page
  # no longer redirecting, and a data call quietly 4xx/5xx-ing while the page
  # renders an empty list. Benchmarx's Next 15 upgrade (BEN-379) hit all three.
  #
  # Baseline confirmed live on staging 2026-11-18: real 404s for unknown
  # page/product/category/branch URLs, 307 /account -> /login?to=/account.

  Scenario Outline: A missing <kind> returns a real 404, not a soft 404
    Then requesting the path "<path>" should return status 404
    Examples:
      | kind     | path                                |
      | page     | /velstar-no-such-page               |
      | product  | /products/velstar-no-such-product   |
      | category | /category/velstar-no-such-category  |
      | branch   | /branches/velstar-no-such-branch    |


  Scenario Outline: The <page> page returns 200 to a direct request
    Then requesting the path "<path>" should return status 200
    Examples:
      | page            | path                                    |
      | home            | /                                       |
      | product         | /products/2440x1220x18mm-marine-plywood |
      | category        | /category/Special-Offers                |
      | category page 2 | /category/Special-Offers?page=2         |
      | search          | /search?q=plywood                       |
      | branch          | /branches/hexham                        |


  Scenario: A guest requesting My Account is redirected to the login page
    Then requesting the path "/account" should return status 307
    Given I navigate directly to the path "/account"
    Then I should eventually be redirected to the "login" page


  # Every fetch/XHR to the storefront itself (Next.js server actions and RSC
  # payloads) or the Peracto API must succeed while browsing the core pages.
  # GeolocationPositionError is expected: the runner denies geolocation, and
  # the branch finder logs it (2026-11-18).
  Scenario: Browsing the core shopping pages raises no failed API calls or page errors
    Given I start monitoring failed network responses from hosts matching "jtdove\.pub$"
    And I start monitoring console errors, ignoring messages matching "Failed to load resource|GeolocationPositionError|cookiebot|Cookiebot|google|gtm|facebook|hotjar|clarity|recaptcha|sf-digi|ERR_BLOCKED|ERR_FAILED"
    When I am on the "home" page
    And I wait for the page to settle
    And I am on the "plp" page
    And I wait for the page to settle
    And I am on the "test-product" page
    And I wait for the page to settle
    And I navigate directly to the path "/search?q=plywood"
    And I wait for the page to settle
    And I am on the "branches" page
    And I wait for the page to settle
    # BEN-390/391 (Benchmarx Next.js 15): branch pages crashed to a 500 after
    # loading (React 19 removed findDOMNode) and the finder never rendered.
    And I am on the "branch-hexham" page
    And I wait for the page to settle
    And I am on the "basket" page
    And I wait for the page to settle
    Then there should be no failed network responses
    And there should be no unexpected console errors
