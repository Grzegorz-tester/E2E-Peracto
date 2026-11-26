@PizzaExpressLive_regression @PE-76
Feature: Backend API contracts

  PE-76 (Peracto 72 -> 79, Symfony 7.4, API Platform 4.3, PHP 8.4) changes the
  API's error format, auth and serialisation. These call the API directly
  (API_BASE_URL in the env file) rather than through the storefront, so a
  contract change shows up as a precise failure instead of a broken page.
  All GETs or unauthenticated requests: safe on production too.

  Baseline captured on staging (Peracto 72.0.1) 2026-11-13, confirmed live:
  /health -> 200 {"message":"Healthy"}; /orders, /users, /addresses -> 401
  "JWT Token not found"; POST /token/refresh with no cookie -> 401 "Missing
  JWT Refresh Token"; unknown route -> 404 with title/status/detail; /menus is
  public and returns hydra:member / hydra:totalItems.

  # PE-76 API-01
  Scenario: The API health endpoint reports healthy
    When I GET the API path "/health"
    Then the response status should be 200
    And the response JSON at "message" should equal "Healthy"

  # PE-76 API-08. Every one of these must refuse an anonymous request: a 200
  # here after the upgrade would mean an access-control rule was lost in the
  # security.yaml / API Platform 4 migration.
  Scenario Outline: The <endpoint> endpoint refuses a request without a token
    When I GET the API path "<endpoint>"
    Then the response status should be 401

    Examples:
      | endpoint   |
      | /orders    |
      | /users     |
      | /addresses |

  # PE-76 AUTH (refresh token now cookie-based and single_use). With no
  # refresh cookie at all the endpoint must still refuse cleanly with a 401,
  # not 500 on the new cookie extractor.
  Scenario: The refresh token endpoint refuses a request with no refresh cookie
    When I POST the API path "/token/refresh"
    Then the response status should be 401

  # PE-76 API error format. API Platform 4 switches to its new error format
  # unless legacy_error_format: true. Both formats carry status/title/detail,
  # which is what the storefront reads, so this passes on either - a failure
  # means the shape the storefront relies on has actually gone.
  Scenario: An unknown API route returns a 404 in the agreed error format
    When I GET the API path "/does-not-exist-velstar"
    Then the response status should be 404
    And the response JSON at "status" should equal "404"
    And the response JSON at "title" should be present
    And the response JSON at "detail" should be present

  # PE-76 API-06. API Platform 4 drops the "hydra:" prefix on collection keys
  # by default (member/totalItems) unless hydra_prefix is kept on. The
  # storefront reads the prefixed keys today, so this is the canary for that.
  Scenario: The public menus collection keeps its shape
    When I GET the API path "/menus"
    Then the response status should be 200
    And the response content-type should contain "application/ld+json"
    And the response JSON at "hydra:totalItems" should be present
    And every entry in the response JSON at "hydra:member" should have a "code" field
    And every entry in the response JSON at "hydra:member" should have a "name" field
