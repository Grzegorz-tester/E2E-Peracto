@regression
Feature: Opening a list's first item shows its detail page

  # Products' first cell is a thumbnail link (no text), so products.json
  # points "first row link" at the SKU cell instead.
  #
  # Read-only: opens each detail page and checks it rendered its own form,
  # but never clicks Save (every detail page here is an edit form).

  Scenario Outline: The first <section> item opens its own detail page
    Given I am navigating the page as a "admin" user
    When I am on the "<list page>" page
    And I click on the "first row link" link
    Then I should be redirected to the "<detail page>" page
    And the "page heading" should contain the text "<heading>"
    And the "detail form" should be displayed

    Examples:
      | section    | list page       | detail page      | heading       |
      | Orders     | orders          | order-detail     | Order #       |
      | Promotions | promotions      | promotion-detail | Edit Promotion |
      | Users      | users           | user-detail      | Edit User     |
      | Tasks      | tasks           | task-detail      | Tasks         |
      | Q&A        | question-answer | question-detail  | Edit question |
      | Products   | products        | product-detail   | Edit Product  |
      | Attribute sets | attributes  | attribute-set-detail | Attribute set |
      | Shipping   | shipping        | shipping-detail  | Edit Shipping service |
      | Forms      | forms           | form-detail      | Edit Form     |
      | Form fields | form-fields    | form-field-detail | Edit Field   |
      | Stockists  | stockists       | stockist-detail  | Edit Stockist |
      | Redirects  | redirects       | redirect-detail  | Edit Redirect |

  # Articles and content templates open straight into the page builder,
  # whose headings are the page's own content, so only the form is checked.
  Scenario Outline: The first <section> item opens its page builder
    Given I am navigating the page as a "admin" user
    When I am on the "<list page>" page
    And I click on the "first row link" link
    Then I should be redirected to the "<detail page>" page
    And the "detail form" should be displayed

    Examples:
      | section           | list page         | detail page             |
      | Articles          | articles          | article-detail          |
      | Content templates | content-templates | content-template-detail |

  # The tree's per-page settings link only shows on hover, so this opens
  # the page builder through the page's name instead.
  Scenario: A content page opens its page builder from the content tree
    Given I am navigating the page as a "admin" user
    When I am on the "content" page
    And I click on the "1st" "content tree page link" element
    Then I should be redirected to the "content-detail" page
    And the "detail form" should be displayed

  # The 1st category in the tree is Bestsellers (id 328), which 500s - see
  # the scenario below - so this opens the 2nd (a standard category).
  Scenario: A category opens from the category tree
    Given I am navigating the page as a "admin" user
    When I am on the "categories" page
    And I click on the "2nd" "first category link" element
    Then I should be redirected to the "category-detail" page
    And the "page heading" should contain the text "Edit Standard Category"
    And the "detail form" should be displayed

  # KNOWN DEFECT (confirmed 2026-10-28): the Bestsellers category's edit page
  # returns HTTP 500 for a Super Admin, while every other category sampled
  # opens fine. Expected to stay red until fixed.
  Scenario: The Bestsellers category opens its edit page
    Given I am navigating the page as a "admin" user
    When I am on the "bestsellers-category" page
    Then the "page heading" should contain the text "Edit"
    And the "detail form" should be displayed

  Scenario: An order's detail page lists its order items
    Given I am navigating the page as a "admin" user
    When I am on the "orders" page
    And I click on the "first row link" link
    Then I should be redirected to the "order-detail" page
    And the "order items table" should be displayed
