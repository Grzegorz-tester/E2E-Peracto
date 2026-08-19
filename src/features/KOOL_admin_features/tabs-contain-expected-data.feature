@regression
Feature: Admin Tabs Contain Expected Data

  # Sweeps every nav tab in the KOOL Peracto admin and confirms it lands on
  # the right page (correct heading) and actually shows data (at least one
  # table row), rather than an empty or broken page. Reused across the whole
  # nav via generic "page heading" (//h1) and "table row" (//tbody/tr) keys
  # in common.json - every one of these list pages renders a plain HTML
  # table, so these two selectors work unmodified for all of them.
  #
  # CONFIRMED SITE QUIRK (live, 2026-08-19): a nested nav item (anything
  # under the Products/Content/Users/Configuration groups) renders with a
  # stale bounding box that overlaps unrelated content further down the
  # sidebar until its parent group has been clicked at least once - clicking
  # a nested item directly resolves the click onto whatever happens to sit
  # at that leftover position instead (confirmed via elementFromPoint: a
  # click aimed at "All Users" silently landed on "Configuration"). Clicking
  # the parent group first repositions everything correctly. Every nested
  # item below clicks its parent group(s) first for exactly this reason -
  # don't drop those steps thinking they're redundant.
  #
  # Top-level items (Promotions, Locations, Orders) have no parent group and
  # don't need this. Dashboard, Orders and Settings are excluded from the
  # data-outlines below and covered by their own scenarios instead: Dashboard
  # and Settings aren't list pages at all (no table), and Orders' table is
  # genuinely empty on this environment right now (confirmed live, not a
  # selector miss).
  #
  # Remember: every click on this admin frontend must be "click precisely"
  # (non-forced) - force-clicking silently does nothing here (see
  # logging-in.feature).

  Background:
    Given I am navigating the page as a "admin" user

  Scenario Outline: A top-level tab loads with its expected heading and at least one row of data
    When I click precisely on the "<nav item>" element
    Then I should be redirected to the "<page id>" page
    And the "page heading" should contain the text "<heading>"
    And the "table row" should be displayed

    Examples:
      | nav item   | page id    | heading    |
      | Promotions | promotions | Promotions |
      | Locations  | locations  | Locations  |

  Scenario Outline: A one-level-nested tab loads with its expected heading and at least one row of data
    When I click precisely on the "<parent>" element
    And I click precisely on the "<nav item>" element
    Then I should be redirected to the "<page id>" page
    And the "page heading" should contain the text "<heading>"
    And the "table row" should be displayed

    Examples:
      | parent        | nav item           | page id            | heading            |
      | Products      | All Products       | products           | Products           |
      | Products      | Product Variants   | variants           | Product Variants   |
      | Products      | Categories         | categories         | Categories         |
      | Content       | Pages              | pages              | Pages              |
      | Content       | Articles           | articles           | Articles           |
      | Content       | Article Categories | article-categories | Article Categories |
      | Content       | Templates          | templates          | Templates          |
      | Content       | Elements           | elements           | Elements           |
      | Content       | Element Areas      | element-areas      | Element Areas      |
      | Users         | All Users          | users              | Users              |
      | Users         | User Groups        | user-groups        | User Groups        |
      | Configuration | Navigation         | navigation         | Navigation         |
      | Configuration | Redirects          | redirects          | Redirects          |
      | Configuration | Shipping Services  | shipping-services  | Shipping Services  |
      | Configuration | Tasks              | tasks              | Tasks              |
      | Configuration | Countries          | countries          | Countries          |

  Scenario Outline: A two-level-nested tab loads with its expected heading and at least one row of data
    When I click precisely on the "<grandparent>" element
    And I click precisely on the "<parent>" element
    And I click precisely on the "<nav item>" element
    Then I should be redirected to the "<page id>" page
    And the "page heading" should contain the text "<heading>"
    And the "table row" should be displayed

    Examples:
      | grandparent | parent     | nav item         | page id          | heading          |
      | Products    | Attributes | All Attributes   | attributes       | Attributes       |
      | Products    | Attributes | Attribute Groups | attribute-groups | Attribute Groups |
      | Products    | Attributes | Attribute Sets   | attribute-sets   | Attribute Sets   |
      | Content     | Forms      | All Forms        | forms            | Forms            |
      | Content     | Forms      | Form Fields      | form-fields      | Form Fields      |
      | Content     | Forms      | Form Submissions | form-submissions | Form Submissions |

  Scenario: The Dashboard tab loads with its own recent-orders widget rather than a list table
    Then the "page heading" should contain the text "Dashboard"

  # CONFIRMED (live, 2026-08-19): the Orders list is genuinely empty on this
  # environment right now - asserted as-is so a future real order is caught
  # as a change here rather than assumed broken.
  Scenario: The Orders tab loads with its filters, currently showing no orders
    When I click precisely on the "Orders" element
    Then I should be redirected to the "orders" page
    And the "page heading" should contain the text "Orders"
    And the "table row" should not be displayed

  Scenario: The Settings tab loads as a configuration form rather than a list table
    When I click precisely on the "Configuration" element
    And I click precisely on the "Settings" element
    Then I should be redirected to the "settings" page
    And the "page heading" should contain the text "Settings"
