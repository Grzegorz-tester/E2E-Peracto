@regression
Feature: Algolia product sync

  # Manual regression cases 223-225 (JTDOVE-2026-11-18.json), added 2026-11-18,
  # plus smoke case 209 (the new product's PDP is live, then 404s once deleted)
  # for the Peracto/API/Next.js upgrade tickets: product search is Algolia
  # (index ALGOLIA_INDEX, objectID = Peracto product id), kept in step with
  # Peracto by the backend, which is exactly what an API or Peracto upgrade
  # can quietly break.
  #
  # Never deletes a real product: the scenario creates its own throwaway
  # "Velstar Test Algolia <timestamp>" product through the staging admin API
  # (users.json "admin" borrows the JTDOVE_ADMIN_ADMIN_* credentials), and an
  # After-hook DELETE removes it even if a step fails.
  #
  # Confirmed live (2026-11-18): a new product is NOT indexed on save; it only
  # reaches Algolia when the "Product Indexer" task runs (nightly at 03:00, or
  # triggered via GET /tasks/product_indexer/run: ~105s for the whole
  # catalogue). A delete IS synced straight away (gone from the index within
  # ~30s). Marine Plywood 310239 is the unrelated product that must survive.

  @mutates-admin-data
  Scenario: A deleted product leaves the Algolia index and storefront search, and other products stay
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I remember a unique value starting with "VELSTAR-ALG-" as "sku"
    When I authenticate against the API as the "admin" user
    And I POST the API path "/products" with the JSON body:
      """
      {
        "sku": "{{sku}}",
        "slug": "velstar-test-algolia-{{sku}}",
        "status": "active",
        "type": "standard",
        "availability": "purchasable",
        "taxRate": "standard",
        "price": 999,
        "attributeSet": "/attribute-sets/30",
        "attributes": [
          { "attribute": "/attributes/1", "value": "Velstar Test Algolia {{sku}}", "locale": "en_GB", "dataType": "string" }
        ]
      }
      """
    Then the response status should be 201
    When I remember the response JSON at "id" as "productId"
    And I will DELETE the API path "/products/{{productId}}" after the scenario

    # Indexed once the Product Indexer runs, and searchable on the storefront.
    When I GET the API path "/tasks/product_indexer/run"
    Then the response status should be 200
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/{{productId}}" until the response status is 200 within 300 seconds
    Then the response JSON at "sku" should equal the remembered "sku"
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with the remembered "sku"
    And I wait for the search results to update
    Then the "first search result" should contain the text "Velstar Test Algolia"
    # Case 209: the new product has its own live PDP.
    When I GET the site path "/products/velstar-test-algolia-{{sku}}" until the response status is 200 within 120 seconds
    Then the response body should contain "Velstar Test Algolia {{sku}}"

    # Case 223: deleting the product removes its record from the index.
    When I DELETE the API path "/products/{{productId}}"
    Then the response status should be 204
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/{{productId}}" until the response status is 404 within 120 seconds
    And I GET the site path "/products/velstar-test-algolia-{{sku}}" until the response status is 404 within 300 seconds

    # Case 224: storefront search no longer finds it.
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "header search input" input field with the remembered "sku"
    Then the "search no results" should be displayed

    # Case 225: an unrelated product is still indexed and searchable.
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/989"
    Then the response status should be 200
    And the response JSON at "sku" should equal "310239"
    When I fill in the "header search input" input field with "310239"
    And I wait for the search results to update
    Then the "first search result" should contain the text "Marine Plywood"
