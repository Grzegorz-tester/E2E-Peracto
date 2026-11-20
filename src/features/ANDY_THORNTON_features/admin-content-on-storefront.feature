@regression @not-on-production
Feature: Admin content changes reach the storefront

  # Smoke cases 29 (create and publish a content page) and 31 (publish it
  # through a navigation menu), from AN-2026-11-19.json. Added 2026-11-19 for
  # AT-185 (Peracto/API upgrade) and AT-201 (Next.js 16): this is the whole
  # admin -> API -> Next.js cache path, which the admin suite alone doesn't see.
  # Ported from JTDove's admin-content-on-storefront.feature.
  #
  # Uses the staging admin API directly (the same requests the admin UI sends),
  # with a throwaway "Velstar Test Page <timestamp>" page that the After hook
  # deletes even if a step fails. users.json "admin" has no AT-specific
  # credentials, so it falls back to the generic ADMIN_* account (the same one
  # the AT admin suite uses).
  #
  # A content page has no storefront URL until it is in a menu; "Orphaned
  # pages" (menuCode orphaned_pages) is the menu for pages that aren't in the
  # visible navigation. AT staging has the same three menus as JTDove
  # (orphaned_pages, main_menu, footer), confirmed via GET /menus 2026-11-19.

  @mutates-admin-data
  Scenario: A content page created and edited in admin is served by the storefront
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I remember a unique value starting with "velstar-test-page-" as "slug"
    When I authenticate against the API as the "admin" user
    And I POST the API path "/contents" with the JSON body:
      """
      {
        "slug": "{{slug}}",
        "type": "page",
        "name": "Velstar Test Page {{slug}}",
        "title": "Velstar Test Page {{slug}}",
        "heading": "Velstar Test Page {{slug}}",
        "searchable": false,
        "publishedAt": "2026-01-01T00:00:00+00:00",
        "locale": "en_GB",
        "body": ["[{\"id\":\"r1\",\"cells\":[{\"id\":\"c1\",\"inline\":null,\"size\":12,\"content\":{\"plugin\":{\"name\":\"peracto/content/text\",\"version\":\"1.0.0\"},\"state\":{\"text\":\"<p>Velstar Test original {{slug}}</p>\"}}}]}]"]
      }
      """
    Then the response status should be 201
    When I remember the response JSON at "id" as "contentId"
    And I will DELETE the API path "/contents/{{contentId}}" after the scenario

    # Not in any menu yet, so it has no storefront URL.
    When I GET the site path "/{{slug}}"
    Then the response status should be 404

    # Case 31: adding it to a menu (Orphaned pages) publishes it at /<slug>.
    When I POST the API path "/menu-items" with the JSON body:
      """
      {
        "itemType": "content",
        "linkType": "external",
        "identifier": {{contentId}},
        "linkText": "Velstar Test Page {{slug}}",
        "menuCode": "orphaned_pages",
        "path": "{{slug}}",
        "image": "",
        "displayFrom": null,
        "displayTo": null
      }
      """
    Then the response status should be 201
    When I remember the response JSON at "id" as "menuItemId"
    And I will DELETE the API path "/menu-items/{{menuItemId}}" after the scenario
    When I GET the site path "/{{slug}}" until the response body contains "Velstar Test original {{slug}}" within 300 seconds
    Then the response status should be 200

    # An edit in admin replaces the cached page.
    When I PUT the API path "/contents/{{contentId}}" with the JSON body:
      """
      {
        "slug": "{{slug}}",
        "type": "page",
        "name": "Velstar Test Page {{slug}}",
        "title": "Velstar Test Page {{slug}}",
        "heading": "Velstar Test Page {{slug}}",
        "searchable": false,
        "publishedAt": "2026-01-01T00:00:00+00:00",
        "locale": "en_GB",
        "body": ["[{\"id\":\"r1\",\"cells\":[{\"id\":\"c1\",\"inline\":null,\"size\":12,\"content\":{\"plugin\":{\"name\":\"peracto/content/text\",\"version\":\"1.0.0\"},\"state\":{\"text\":\"<p>Velstar Test edited {{slug}}</p>\"}}}]}]"]
      }
      """
    Then the response status should be 200
    When I GET the site path "/{{slug}}" until the response body contains "Velstar Test edited {{slug}}" within 300 seconds
    Then the response body should not contain "Velstar Test original {{slug}}"

    # And a browser renders it as a normal page.
    Given I navigate directly to the path "/{{slug}}"
    And I wait for the page to settle
    Then the "not found heading" should not be displayed
    And the "content page body" should contain the text "Velstar Test edited"
    And the "content page body" should contain the remembered "slug"
