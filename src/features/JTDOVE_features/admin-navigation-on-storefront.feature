@menu-cache
Feature: Admin navigation changes reach the storefront

  # Manual case 208 (add a content page to navigation), from the QA smoke
  # export JTDOVE-2026-11-18 (1).json, added 2026-11-19. NOT in @regression or
  # @smoke on purpose: run it on demand with the menu_cache profile (./run_tests.sh menu_cache).
  # See admin-content-on-storefront.feature for the content/menu API details.

  # Confirmed live 2026-11-19: menus are cached separately from pages and
  # unpredictably. Three tries at a new footer link took 19s, ~12 minutes,
  # and more than 15 minutes (the step's maximum). Until the menu cache is
  # sorted out (raise with the devs via the AM), this can't be a reliable
  # regression check. The link is a child of the footer's "About JT Dove"
  # column (menu item 238) and is deleted afterwards, but can linger in the
  # cached footer for a few minutes.
  @mutates-admin-data
  Scenario: A content page added to the footer navigation appears in the storefront footer
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I remember a unique value starting with "velstar-test-footer-" as "slug"
    When I authenticate against the API as the "admin" user
    And I POST the API path "/contents" with the JSON body:
      """
      {
        "slug": "{{slug}}",
        "type": "page",
        "name": "Velstar Test Footer {{slug}}",
        "title": "Velstar Test Footer {{slug}}",
        "heading": "Velstar Test Footer {{slug}}",
        "searchable": false,
        "publishedAt": "2026-01-01T00:00:00+00:00",
        "locale": "en_GB",
        "body": ["[{\"id\":\"r1\",\"cells\":[{\"id\":\"c1\",\"inline\":null,\"size\":12,\"content\":{\"plugin\":{\"name\":\"peracto/content/text\",\"version\":\"1.0.0\"},\"state\":{\"text\":\"<p>Velstar Test footer page {{slug}}</p>\"}}}]}]"]
      }
      """
    Then the response status should be 201
    When I remember the response JSON at "id" as "contentId"
    And I will DELETE the API path "/contents/{{contentId}}" after the scenario
    When I POST the API path "/menu-items" with the JSON body:
      """
      {
        "itemType": "content",
        "linkType": "external",
        "identifier": {{contentId}},
        "linkText": "Velstar Test Footer {{slug}}",
        "menuCode": "footer",
        "parent": "/menu-items/238",
        "path": "{{slug}}",
        "image": "",
        "displayFrom": null,
        "displayTo": null
      }
      """
    Then the response status should be 201
    When I remember the response JSON at "id" as "menuItemId"
    And I will DELETE the API path "/menu-items/{{menuItemId}}" after the scenario

    When I GET the site path "/" until the response body contains "Velstar Test Footer {{slug}}" within 900 seconds
    Given I am on the "home" page
    And I wait for the page to settle
    # A previous run's link can still be in the cached footer, so pick ours.
    When I click on the "velstar test footer link" link containing the remembered "slug"
    Then the current URL should contain "/velstar-test-footer-"
    And I wait for the page to settle
    And the "content page body" should contain the text "Velstar Test footer page"
