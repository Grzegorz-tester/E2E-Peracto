@algolia-sync @not-on-production
Feature: Admin products reach Algolia search and the storefront

  # Smoke case 32 (create a product in admin, it appears on the storefront and
  # its PDP loads) from AN-2026-11-19.json, plus AT-185's own post-deploy
  # checklist item "Algolia indexing". Added 2026-11-19; ported from JTDove's
  # algolia-product-sync.feature. PLP, search and autocomplete are all Algolia
  # (index ALGOLIA_INDEX, objectID = Peracto product id, confirmed live on
  # product 949), kept in step with Peracto by the backend: exactly what a
  # Peracto/Symfony/Doctrine upgrade can quietly break.
  #
  # Never touches a real product: it creates its own throwaway
  # "Velstar Test Algolia <timestamp>" product (attribute set 54 "General")
  # through the staging admin API, and an After-hook DELETE removes it even if
  # a step fails. On JTDove a new product only reached Algolia when the
  # "product_indexer" task ran, so this triggers it rather than waiting for the
  # nightly run; AT has the same task (GET /tasks, 2026-11-19).
  #
  # NOT in @regression on purpose: run it on demand with --tags @algolia-sync.
  # SITE FINDING (staging, 2026-11-19, AT-185 already deployed there): a
  # product deleted in Peracto is NOT removed from Algolia (on JTDove it is,
  # within ~30s). Product 7742 was still indexed and still listed by storefront
  # search (card linking to a dead PDP) over an hour later, even after
  # re-running product_indexer. So each run leaves a ghost "Velstar Test
  # Algolia" product in staging search, and the delete check stays red, until
  # the devs fix the delete sync (or confirm it's by design). Production can't
  # be checked (read-only), so whether AT-185 caused it is unknown.

  @mutates-admin-data
  Scenario: A product created in admin is indexed, searchable and has a PDP, and leaves search once deleted
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
        "attributeSet": "/attribute-sets/54",
        "attributes": [
          { "attribute": "/attributes/1", "value": "Velstar Test Algolia {{sku}}", "locale": "en_GB", "dataType": "string" }
        ]
      }
      """
    Then the response status should be 201
    When I remember the response JSON at "id" as "productId"
    And I will DELETE the API path "/products/{{productId}}" after the scenario

    # Indexed once the Product Indexer runs.
    When I GET the API path "/tasks/product_indexer/run"
    Then the response status should be 200
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/{{productId}}" until the response status is 200 within 300 seconds
    Then the response JSON at "sku" should equal the remembered "sku"

    # Case 32: the new product has its own live PDP.
    When I GET the site path "/products/velstar-test-algolia-{{sku}}" until the response status is 200 within 120 seconds
    Then the response body should contain "Velstar Test Algolia {{sku}}"

    # Case 24: searching by SKU finds it, and the result opens its PDP.
    Given I navigate directly to the path "/search?q={{sku}}"
    And I wait for the page to settle
    Then the "first product name" should contain the text "Velstar Test Algolia"
    When I click on the "first product card" element
    Then I should eventually be redirected to the "product" page
    And the "product name" should contain the remembered "sku"

    # Deleting the product removes it from the index and from search.
    When I DELETE the API path "/products/{{productId}}"
    Then the response status should be 204
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/{{productId}}" until the response status is 404 within 180 seconds
    Given I navigate directly to the path "/search?q={{sku}}"
    And I wait for the page to settle
    Then the "no search results" should be displayed

    # An unrelated product is still indexed and searchable by SKU.
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/949"
    Then the response status should be 200
    And the response JSON at "sku" should equal "ATFUOF1104"
