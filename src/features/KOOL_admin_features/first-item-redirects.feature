@regression
Feature: Clicking The First Item In Each Tab Redirects Correctly

  # For every admin section with real data rows, clicks the first item in
  # its list and confirms it lands on a genuine detail/edit page for that
  # specific item - not just "some page", but the right kind of page with
  # the right kind of heading. Item IDs are live data and can change, so
  # this checks the URL contains the section's own path (e.g. "/products/")
  # rather than an exact ID, and that a heading element actually renders.
  #
  # CONFIRMED (live, 2026-08-19): most sections use "/{route}/{id}" with a
  # numeric ID and an <h1> heading. Four Content sub-types (Pages, Articles,
  # Templates, Elements) instead use "/content/edit/{type}/{id}" and render
  # their heading as an <h2>, not an <h1> - "content edit heading" in
  # common.json covers those. Element Areas/User Groups/Tasks use a slug
  # instead of a numeric ID but still fit the "/{route}/{slug}" + <h1>
  # pattern. Product Variants nests under its parent product instead
  # ("/products/{id}/variants/{variantId}").
  #
  # CONFIRMED GAP (live, 2026-08-19): Countries' single row (United Kingdom)
  # has no link at all in its row - only two checkbox toggles - so there is
  # no detail page to click through to. Not covered here; not a selector
  # miss, there is genuinely nothing to click.
  #
  # Remember: every click on this admin frontend must be "click precisely"
  # (non-forced) - force-clicking silently does nothing here.

  Background:
    Given I am navigating the page as a "admin" user

  Scenario Outline: The first item in a top-level tab opens its own detail page
    When I click precisely on the "<nav item>" element
    And I click precisely on the "first item link" element
    Then the current URL should contain "<url fragment>"
    And the "page heading" should be displayed

    Examples:
      | nav item   | url fragment  |
      | Promotions | /promotions/  |
      | Locations  | /locations/   |

  Scenario Outline: The first item in a one-level-nested tab opens its own detail page
    When I click precisely on the "<parent>" element
    And I click precisely on the "<nav item>" element
    And I click precisely on the "first item link" element
    Then the current URL should contain "<url fragment>"
    And the "<heading key>" should be displayed

    Examples:
      | parent        | nav item           | url fragment           | heading key           |
      | Products      | All Products       | /products/             | page heading          |
      | Products      | Product Variants   | /variants/             | page heading          |
      | Products      | Categories         | /categories/           | page heading          |
      | Content       | Pages              | /content/edit/page/    | content edit heading  |
      | Content       | Articles           | /content/edit/article/ | content edit heading  |
      | Content       | Article Categories | /article-categories/   | page heading          |
      | Content       | Templates          | /content/edit/template/| content edit heading  |
      | Content       | Elements           | /content/edit/element/ | content edit heading  |
      | Content       | Element Areas      | /element-areas/        | page heading          |
      | Users         | All Users          | /users/                | page heading          |
      | Users         | User Groups        | /user-groups/          | page heading          |
      | Configuration | Redirects          | /redirects/            | page heading          |
      | Configuration | Shipping Services  | /shipping-services/    | page heading          |
      | Configuration | Tasks              | /tasks/                | page heading          |

  Scenario Outline: The first item in a two-level-nested tab opens its own detail page
    When I click precisely on the "<grandparent>" element
    And I click precisely on the "<parent>" element
    And I click precisely on the "<nav item>" element
    And I click precisely on the "first item link" element
    Then the current URL should contain "<url fragment>"
    And the "page heading" should be displayed

    Examples:
      | grandparent | parent     | nav item         | url fragment        |
      | Products    | Attributes | All Attributes   | /attributes/        |
      | Products    | Attributes | Attribute Groups | /attribute-groups/  |
      | Products    | Attributes | Attribute Sets   | /attribute-sets/    |
      | Content     | Forms      | All Forms        | /forms/             |
      | Content     | Forms      | Form Fields      | /form-fields/       |
      | Content     | Forms      | Form Submissions | /form-submissions/  |

  # Navigation's list holds fixed, named menus (Orphaned pages/Main menu/
  # Footer) rather than arbitrary rows, so its own specific link is used
  # instead of a generic "first item link".
  Scenario: The first item in Navigation (Orphaned pages) opens its own detail page
    When I click precisely on the "Configuration" element
    And I click precisely on the "Navigation" element
    And I click precisely on the "Orphaned pages" element
    Then the current URL should contain "/menus/orphaned_pages"
    And the "page heading" should be displayed
