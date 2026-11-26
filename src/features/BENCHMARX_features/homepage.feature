@regression
Feature: Homepage

  # BEN-379 (Next.js 15 upgrade) HP-01 to HP-04. Built 2026-11-11 from a live
  # inspection of staging. The homepage is a Peracto content page: hero,
  # "Browse by type" buttons (True Handleless, J-Pull, Slab, Shaker), the
  # 2020 kitchen visualiser and the virtual showroom. Some CTAs are
  # hardcoded absolute links to www.benchmarxkitchens.co.uk (live) in the
  # CMS on staging too, so only first-party relative links are clicked.

  # HP-01
  Scenario: The homepage hero renders and its content links resolve
    Given I am on the "home" page
    Then the "page heading" should contain the text "A kitchen for every style and budget"
    And the "content page" should be displayed
    And the "first content image" should be displayed
    And the "first content image" image should return a 200 OK response with content-type "image/"
    And all "content links" links should resolve without an error

  # HP-02 and PLP-07. One "Browse" button: the other three are the same
  # component, and their hrefs are already resolved by HP-01's content links
  # check. Also covers the range landing page (was a separate six-range
  # outline in shop-plp.feature until 2026-11-22).
  Scenario: The "Browse Shaker" button opens the Shaker range listing
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "Browse Shaker" link
    Then I should be redirected to the "kitchen-range" page
    And the current URL should contain "/kitchen-ranges/shaker"
    And the "page heading" should be displayed
    And the "product cards" should be displayed
    And the "hit count" should be displayed

  # HP-03: the virtual showroom is an embed on its own page.
  Scenario: The homepage's virtual showroom button opens the showroom page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "Enter virtual showroom" link
    Then I should be redirected to the "ideas-inspiration-page" page
    And the "content page" should be displayed
    And the "breadcrumb" should be displayed
    And requesting the path "/ideas-inspiration/virtual-showroom" should return status 200

  Scenario: The kitchen visualiser page loads
    Given I navigate directly to the path "/ideas-inspiration/kitchen-visualiser"
    Then the "content page" should be displayed
    And requesting the path "/ideas-inspiration/kitchen-visualiser" should return status 200

  # HP-04
  Scenario: The homepage's next steps tiles resolve
    Given I am on the "home" page
    Then the "next steps" should be displayed
    And all "next steps links" links should resolve without an error
