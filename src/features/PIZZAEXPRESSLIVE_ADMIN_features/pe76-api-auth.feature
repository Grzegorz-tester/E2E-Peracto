@regression @PE-76
Feature: PE-76 API authentication and refresh tokens

  PE-76 moves the JWT refresh token config to cookie-based and single_use
  (gesdinet/jwt-refresh-token-bundle on Symfony 7.4). These call the API
  directly with the admin test account (API_BASE_URL in the env file), so
  they hold whatever the admin frontend ends up doing with the tokens.

  Baseline CONFIRMED live on staging (Peracto 72.0.1), 2026-11-14:
  POST /auth returns token + refresh_token in the body AND sets "bearer" and
  "refresh_token" cookies, both HttpOnly, Secure, SameSite=None. A refresh
  with only the cookie returns 200 and a new (rotated) refresh token. A used
  refresh token, a second use of the rotated one, and a garbage token all
  return 401 "JWT Refresh Token Not Found". The admin frontend itself ignores
  the cookies today and keeps its tokens in localStorage.

  # PE-76 AUTH-02. SameSite=None is what staging sends today (the admin and
  # API are on different subdomains). If dev deliberately changes it as part
  # of PE-76, update the expected value here rather than treating it as a bug.
  Scenario: Logging in sets the refresh token as an HttpOnly, Secure cookie
    When I POST the API path "/auth" with the "admin" user's credentials
    Then the response status should be 200
    And the response JSON at "token" should be present
    And the response should set the "refresh_token" cookie with "HttpOnly, Secure, SameSite=None"
    And the response should set the "bearer" cookie with "HttpOnly, Secure, SameSite=None"

  # PE-76 AUTH-03 (API side). A refresh carrying nothing but the cookie the
  # login set must succeed, rotate the refresh token, and hand back an
  # access token that works.
  Scenario: The refresh token cookie alone refreshes the session and rotates the token
    When I POST the API path "/auth" with the "admin" user's credentials
    And I remember the response JSON at "refresh_token" as "first refresh token"
    And I POST the API path "/token/refresh"
    Then the response status should be 200
    And the response JSON at "token" should be present
    And the response JSON at "refresh_token" should not equal the remembered "first refresh token"
    And the response should set the "refresh_token" cookie with "HttpOnly, Secure, SameSite=None"

  # PE-76 AUTH-04. single_use: once a refresh token has been used it must be
  # rejected, whether it is replayed by the original client or by someone
  # who captured it. Cookies are cleared first so only the replayed token is
  # sent, not the newer rotated cookie.
  Scenario: A used refresh token cannot be replayed
    When I POST the API path "/auth" with the "admin" user's credentials
    And I remember the response JSON at "refresh_token" as "first refresh token"
    And I POST the API path "/token/refresh" with the remembered "first refresh token" as the JSON field "refresh_token"
    Then the response status should be 200
    When I clear the browser's cookies
    And I POST the API path "/token/refresh" with the remembered "first refresh token" as the JSON field "refresh_token"
    Then the response status should be 401

