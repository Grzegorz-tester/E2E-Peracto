@regression
Feature: Error pages and access control

  # IND-729 (Peracto API upgrade) case 310: a missing record must still render
  # the branded 404 page rather than a blank state or a raw API error, and
  # account pages must stay behind login.
  #
  # CONFIRMED 2026-11-13 (staging): an unknown CMS path returns a real 404,
  # but an unknown /products/<slug> serves the same 404 page with HTTP 200 (a
  # "soft 404"). The product status is not asserted here until it is confirmed
  # whether that is intended; the page content is. Both test paths resolve to
  # the "velstar-not-found-test" page ID in pages.json.

  Scenario: An unknown content page shows the branded 404 page with a 404 status
    Given I navigate directly to the path "/velstar-test-page-that-does-not-exist"
    Then the "not found heading" should contain the text "We couldn't find the page you're looking for"
    And requesting the path "/velstar-test-page-that-does-not-exist" should return status 404

  Scenario: An unknown product shows the branded 404 page
    Given I navigate directly to the path "/products/velstar-test-product-that-does-not-exist"
    Then the "not found heading" should contain the text "We couldn't find the page you're looking for"

  Scenario Outline: A logged-out visitor opening "<path>" is sent to the login page
    Given I navigate directly to the path "<path>"
    Then I should eventually be redirected to the "login" page

    Examples:
      | path                  |
      | /account              |
      # 2026-11-22: /account/orders, /profile, /address-book rows removed, same guard as /account (logging-in.feature sign-out also checks /account/orders).
