@regression @HIB-179
Feature: Algolia product sync

  # Added 2026-11-19 for HIB-179: the product_indexer task that keeps Algolia
  # in step with Peracto runs as a Lambda, and the PHP 8.5 / Bref v3 upgrade
  # moves it to a new runtime. Search is Algolia (ALGOLIA_INDEX, objectID =
  # Peracto product id).
  #
  # Confirmed live on staging 2026-11-19:
  # - A product is NOT indexed on save; it reaches Algolia ~40s after the
  #   indexer runs (GET /tasks/product_indexer/run). Staging's nightly
  #   schedule is inactive, so the scenario triggers it itself.
  # - A DELETED product is NEVER removed from Algolia, not straight away and
  #   not by a later indexer run. Staging's index held 13 such ghost records
  #   (12 left by our own admin-suite product scenarios), still searchable.
  #   That's why this scenario never creates or deletes a product: it renames
  #   a permanent fixture instead, so it adds nothing to the index.
  # - The release storefront searches STAGING's index, and the hib-170
  #   release wrote its own products into it (objectIDs 741-754, above
  #   staging's highest id). A release product overwrites any staging record
  #   with the same id, so this runs on staging only:
  #   @writes-shared-algolia-index is excluded in env/HIB_RELEASE.env.
  #
  # Fixture, do not delete: staging product 740 "Velstar Test Algolia
  # Fixture" (SKU VELSTAR-ALGOLIA-FIXTURE, attribute set Core), whose
  # product_name is product-attribute 15235. Created 2026-11-19.

  @mutates-admin-data @writes-shared-algolia-index
  Scenario: Renaming a product reaches the Algolia index and storefront search, and other products stay
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I remember a unique value starting with "Velstar Test Algolia Fixture " as "name"
    When I authenticate against the API as the "admin" user
    And I PUT the API path "/product-attributes/15235" with the JSON body:
      """
      { "value": "{{name}}" }
      """
    Then the response status should be 200

    When I GET the API path "/tasks/product_indexer/run"
    Then the response status should be 200
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/740" until the response body contains "{{name}}" within 300 seconds
    Then the response JSON at "sku" should equal "VELSTAR-ALGOLIA-FIXTURE"

    # Searching the new, unique name finds the fixture on the storefront.
    Given I am on the "home" page
    And I dismiss the newsletter popup if present
    When I fill in the "Search products" input field with the remembered "name"
    And I wait for the search results to update
    Then the "first search result" should contain the text "Velstar Test Algolia Fixture"

    # An unrelated product survives the reindex: Vanquish cabinet, id 284.
    When I GET the Algolia path "/1/indexes/{{env.ALGOLIA_INDEX}}/284"
    Then the response status should be 200
    And the response JSON at "sku" should equal "58373"
