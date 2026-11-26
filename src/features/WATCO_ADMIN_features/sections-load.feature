@regression
Feature: Admin sections load with real content

  # Read-only. Each section the Admin role can open must load its own page
  # with a populated list, not an error page.
  #
  # The account needs Super Admin: with only the Admin role every section
  # from Products down returns a slow HTTP 500 instead of a 403 (confirmed
  # 2026-10-28, see NOTES.md). Akeneo reporting (live API calls) and the
  # export pages (generate customer-data files) are deliberately left out
  # even though they're read-only in name.

  # Rows removed 2026-11-22 (Promotions, Users, Tasks, Q&A, Products, Attributes, Shipping, Articles, Content templates, Forms, Form fields, Stockists, Redirects): first-item-opens-detail.feature opens the same lists and fails if a list has no first row.
  Scenario Outline: The <section> section loads with its list
    Given I am navigating the page as a "admin" user
    When I am on the "<page>" page
    Then the "page heading" should contain the text "<heading>"
    And the "list rows" should be displayed

    Examples:
      | section          | page                 | heading   |
      | Orders           | orders               | Orders    |
      | Stockist settings | stockist-settings   | Settings  |
      | Permission resources | permission-resources | Resources |
      | Store settings   | store-settings       | Settings  |
      | Product imports  | product-imports      | Import    |
      | Settings         | settings             | Settings  |
      | Store banner     | store-banner         | Store Banner Settings |
      | Announcement banner | announcement-banner | Announcement Banner Settings |
      | Dashboard banner | dashboard-banner     | Dashboard Banner Settings |

  Scenario Outline: The <section> tree loads
    Given I am navigating the page as a "admin" user
    When I am on the "<page>" page
    Then the "page heading" should contain the text "<heading>"
    And the "tree items" should be displayed

    Examples:
      | section    | page       | heading    |
      | Categories | categories | Categories |
      | Content    | content    | Content    |

  Scenario Outline: The <section> settings form loads
    Given I am navigating the page as a "admin" user
    When I am on the "<page>" page
    Then the "page heading" should contain the text "<heading>"
    And the "detail form" should be displayed

    Examples:
      | section               | page                  | heading               |
      | Search settings       | search-settings       | Search settings       |
      | Product finder banner | product-finder-banner | Product Finder Banner |
      | Marketing banner      | marketing-banner      | Marketing Banner      |
      | Professional message  | professional-message  | Are You A Professional Message |

  Scenario: The Permissions matrix lists every resource
    Given I am navigating the page as a "admin" user
    When I am on the "permissions" page
    Then the "page heading" should contain the text "Permissions"
    And the "permissions table rows" should be displayed
