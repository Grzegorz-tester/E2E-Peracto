@regression
Feature: Storefront data calls succeed across key journeys

  # IND-729 (Peracto API upgrade) case 307. A changed API contract (e.g.
  # api-platform 4 renaming hydra:member to member) most likely shows up as a
  # failed data call or a JS crash that the page renders as an empty state,
  # not as a visible error. These walk the main pages and fail on any 4xx/5xx
  # fetch/XHR from the storefront origin or the Peracto API, or any uncaught
  # page error / console error.
  #
  # CONFIRMED 2026-11-13 (staging, pre-upgrade): most data goes through the
  # storefront's own origin (Next.js), a few calls go straight to
  # staging-api.indespension.pub; zero failed responses. As of then the API
  # still returns hydra: prefixed collection keys.
  #
  # Ignored console noise (third-party, not ours): requestStorageAccess
  # (Cookiebot/ads), geolocation denial (permissions are denied on purpose,
  # see CLAUDE.md), and the Google Maps referrer error that is a known staging
  # defect (see NOTES.md). Branch finder is left out for the same reason.
  # Also ignored: one broken staging image on /towbars, CONFIRMED 2026-11-13:
  # staging's content references "towbar-fitting-call-to-action correct (1)
  # no text.png", which the assets host 403s; production references a
  # different, working .jpeg. A staging content issue, not an API one.
  # Production only: Cookiebot is blocked by the prod env (BLOCK_REQUEST_HOSTS),
  # which logs "Failed to load resource" for consent.cookiebot.com, and a
  # report-only CSP notice about framing google.com (reCAPTCHA). Both ignored
  # (CONFIRMED 2026-11-13); neither is an API problem.
  # NOTES.md mentions Cloudflare 503s on sitemap hover prefetch; none seen on
  # these pages, so nothing is ignored on the network side yet.

  Background:
    Given I start monitoring failed network responses from hosts matching "indespension\.(pub|co\.uk)$"
    And I start monitoring console errors, ignoring messages matching "requestStorageAccess|GeolocationPositionError|user position|RefererNotAllowedMapError|Google Maps|towbar-fitting-call-to-action%20correct|consent\.cookiebot\.com|\[Report Only\]"

  Scenario: Browsing as a guest through PLP, PDP, search and basket makes no failed data calls
    Given I am navigating the page as a "guest" user
    And I wait for the page to settle
    When I am on the "used-trailers" page
    And I wait for the page to settle
    Then the "first product name" should be displayed
    When I am on the "blueline-trailer-pdp" page
    And I wait for the page to settle
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears
    And I navigate directly to the path "/search?q=jockey"
    And I wait for the page to settle
    Then the "products cards" should be displayed
    When I am on the "basket" page
    And I wait for the page to settle
    Then the "basket item" should be displayed
    When I am on the "towbars" page
    And I wait for the page to settle
    Then there should be no failed network responses
    And there should be no unexpected console errors

  Scenario: Browsing a logged-in account makes no failed data calls
    Given I am navigating the page as a "logged in" user
    And I wait for the page to settle
    When I am on the "account-orders" page
    And I wait for the page to settle
    And I click on the "first order row" element
    Then I should be redirected to the "account-order-detail" page
    And the "order reference" should be displayed
    When I am on the "account-address-book" page
    And I wait for the page to settle
    And I am on the "account-profile" page
    And I wait for the page to settle
    Then there should be no failed network responses
    And there should be no unexpected console errors
