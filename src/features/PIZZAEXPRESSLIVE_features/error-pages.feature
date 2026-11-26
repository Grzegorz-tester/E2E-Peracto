@PizzaExpressLive_regression @PE-76
Feature: Error pages

  # PE-76 API-02. An unknown event must reach the storefront's own 404 page
  # with a real 404 status, not a 500 from a changed API error response.
  Scenario: An unknown event shows the 404 page with a 404 status
    When I GET the site path "/whats-on/does-not-exist-velstar"
    Then the response status should be 404
    When I navigate directly to the path "/whats-on/does-not-exist-velstar"
    Then a heading with the text "404" should be displayed
    And a heading with the text "We couldn't find the page you're looking for" should be displayed

  Scenario: An unknown page shows the 404 page with a 404 status
    When I GET the site path "/does-not-exist-velstar"
    Then the response status should be 404
    When I navigate directly to the path "/does-not-exist-velstar"
    Then a heading with the text "404" should be displayed
