@regression
Feature: Accessories, appliances and joinery

  # BEN-379 (Next.js 15 upgrade) ACC-01, ACC-02, ACC-05. Built 2026-11-11
  # from a live inspection of staging. These are Peracto content pages
  # (tiles of image + link), not Algolia listings: Accessories and
  # appliances links to /accessories, /appliances, /lighting, /sinks-taps
  # and /worktops-splashbacks; Joinery to /doors-windows-joinery and
  # /flooring-and-underfloor-heating. Their tiles use RELATIVE hrefs (e.g.
  # "accessories/kitchen-handles"), resolved against the page URL.

  # ACC-01
  Scenario Outline: The <page> landing page's tiles render and link to real pages
    Given I am on the "<page>" page
    Then the "content page" should be displayed within "30" seconds
    And the "page heading" should be displayed
    And the "first content image" should be displayed
    And the "first content image" image should return a 200 OK response with content-type "image/"
    And all "content tile links" links should resolve without an error

    Examples:
      | page                       |
      | accessories-and-appliances |

  # ACC-02, ACC-05
  Scenario Outline: The <subcategory> subcategory page renders and its tiles resolve
    Given I navigate directly to the path "/<subcategory>"
    Then I should be redirected to the "accessories-subcategory" page
    And the "content page" should be displayed within "30" seconds
    And the "page heading" should be displayed
    And the "breadcrumb" should be displayed
    And the "first content image" should be displayed
    And all "content tile links" links should resolve without an error

    Examples:
      | subcategory                     |
      | accessories                     |
      | doors-windows-joinery           |

  # ACC-04: a detail page beneath a subcategory (some, e.g. appliances/ovens,
  # have no h1 on staging).
  Scenario Outline: The <detail> detail page renders
    Given I navigate directly to the path "/<detail>"
    Then the "content page" should be displayed within "30" seconds
    And the "first content image" should be displayed
    And requesting the path "/<detail>" should return status 200

    Examples:
      | detail                             |
      | accessories/kitchen-handles        |
