@regression @HIB-179
Feature: Backend API health (PHP 8.5 / Bref v3 upgrade)

  # Added 2026-11-19 for HIB-179 (API moves from PHP 8.2 to 8.5 and from Bref
  # v2 to v3, so every Lambda gets a new runtime). These call the API directly
  # (API_BASE_URL in the env file) rather than through the storefront, so a
  # broken runtime, a PHP deprecation/warning leaking into a response, or a
  # missing migration fails precisely instead of as a vague broken page.
  # Everything here is a GET or a login POST: safe on production too.
  #
  # Baseline confirmed live on staging (PHP 8.2), release 2-17-0 and
  # production, 2026-11-19: the entrypoint and /menus, /locations, /forms are
  # public; /orders, /users, /addresses, /baskets, /products, /categories all
  # answer 401 "JWT Token not found" without a token; an unknown route is a
  # 404 with status/title/detail.
  #
  # KNOWN RED on release 2-17-0 (2026-11-19): POST /auth with VALID
  # credentials (storefront and admin account alike) returns 500 "Unknown
  # column 't0.replaced_by' in 'field list'", i.e. a database migration has
  # not run on that environment. Wrong credentials still give a clean 401.
  # Staging logs in fine with the same accounts. Every logged-in storefront
  # scenario and the whole HIB_ADMIN suite fail on 2-17-0 until it is fixed.

  # A PHP warning or deprecation printed before the JSON (staging's PHP JIT
  # "<!-- Warning ..." on 2026-10-14 was exactly this) makes the body invalid
  # JSON, which "should be present" catches as "not JSON".
  Scenario: The API entrypoint answers with clean JSON-LD
    When I GET the API path "/"
    Then the response status should be 200
    And the response content-type should contain "application/ld+json"
    And the response JSON at "@type" should equal "Entrypoint"
    And the response body should not contain "Deprecated:"
    And the response body should not contain "Warning:"


  Scenario Outline: The public <endpoint> collection loads without a token
    When I GET the API path "<endpoint>"
    Then the response status should be 200
    And the response JSON at "hydra:totalItems" should be present
    And the response body should not contain "Deprecated:"
    Examples:
      | endpoint                  |
      | /menus                    |
      | /locations?itemsPerPage=1 |
      | /forms?itemsPerPage=1     |


  # A 200 here after the upgrade would mean an access-control rule was lost.
  Scenario Outline: The <endpoint> endpoint refuses a request without a token
    When I GET the API path "<endpoint>"
    Then the response status should be 401
    Examples:
      | endpoint                       |
      | /orders                        |
      | /users                         |
      | /addresses                     |
      | /baskets                       |
      | /products?itemsPerPage=1       |
      | /categories?itemsPerPage=1     |


  Scenario: An unknown API route returns a 404 in the agreed error format
    When I GET the API path "/velstar-does-not-exist"
    Then the response status should be 404
    And the response JSON at "status" should equal "404"
    And the response JSON at "title" should be present
    And the response JSON at "detail" should be present


  # The login a shopper's session depends on, checked at the source.
  Scenario: The storefront test account can log in to the API and read its addresses
    When I authenticate against the API as the "logged in" user
    And I GET the API path "/addresses"
    Then the response status should be 200
    And the response JSON at "hydra:member" should be present


  # The scheduled Lambdas HIB-179 moves to the Bref v3 runtime (SAP auth and
  # order sync, the Algolia indexer, the sitemaps) must all still be
  # registered as tasks. Read-only, so it runs on production too.
  Scenario Outline: The "<task>" scheduled task is still registered
    When I authenticate against the API as the "admin" user
    And I GET the API path "/tasks?itemsPerPage=50"
    Then the response status should be 200
    And the response JSON at "hydra:member" should contain an entry whose "code" is "<task>"
    Examples:
      | task               |
      | sap_authentication |
      | sap_update_orders  |
      | product_indexer    |
      | sitemap_products   |
      | sitemap_content    |
      | sitemap_categories |
