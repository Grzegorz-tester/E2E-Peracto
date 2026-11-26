@PizzaExpressLive_regression @PE-76
Feature: Similar events (product relations)

  PE-76 API-05 / DB-07. Peracto 79 changes the product relations DTO, and the
  storefront's "Similar Events" carousel is built from it
  (pageProps.relations[].relatedProduct). Most events have no relations, so
  this uses a fixed event that has four on staging (confirmed live
  2026-11-13). If staging is refreshed from a prod copy and this event goes,
  pick another with relations (the sitemap + __NEXT_DATA__ scan in
  config/PIZZAEXPRESSLIVE_config/NOTES.md finds one).

  @not-on-production
  Scenario: An event with relations shows its similar events
    Given I navigate directly to the path "/whats-on/filomena-campus-quartet-with-steve-lodder-charlie-pyne-and-rod-youngs"
    Then I should be redirected to the "pdp" page
    And a heading with the text "Similar Events" should be displayed
    And the "similar events link" should be displayed
    When I read window.__NEXT_DATA__
    Then every entry in the page data at "props.pageProps.relations" should have a "relatedProduct" field
    And the page data at "props.pageProps.relations[0].relatedProduct.slug" should be present
    And the page data at "props.pageProps.relations[0].relatedProduct.sku" should be present
    And the page data at "props.pageProps.event.similarEvents[0].slug" should be present
