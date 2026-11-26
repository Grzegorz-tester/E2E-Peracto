@regression
Feature: Admin content changes reach the storefront

  # Manual case 206 (create and publish a content page; case 208, adding it
  # to navigation, is in admin-navigation-on-storefront.feature), from the QA smoke export
  # JTDOVE-2026-11-18 (1).json. Added 2026-11-19 for the Peracto/API/Next.js
  # upgrade tickets: this is the whole admin -> API -> Next.js cache path,
  # which the admin suite alone doesn't see.
  #
  # Uses the staging admin API directly (the same requests the admin UI
  # sends, captured live 2026-11-19), with a throwaway "Velstar Test Page
  # <timestamp>" page that the After hook deletes even if a step fails.
  #
  # Confirmed live 2026-11-19:
  # - A content page has no storefront URL until it is in a menu: a page
  #   with no menu item 404s. "Orphaned pages" is the menu for pages that
  #   aren't in the visible navigation. The menu item's "identifier" is the
  #   numeric content id; "menuCode" picks the menu.
  # - The new page is served at /<slug> straight away, and an edit shows on
  #   the storefront within about 40s.

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

    # Case 206: publishing it (Orphaned pages) serves it at /<slug>.
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
    When I GET the site path "/{{slug}}" until the response body contains "Velstar Test original {{slug}}" within 120 seconds
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
    # Content pages render the body only (no <h1> heading), so check its text.
    Then the "not found heading" should not be displayed
    And the "content page body" should contain the text "Velstar Test edited"
    And the "content page body" should contain the remembered "slug"
