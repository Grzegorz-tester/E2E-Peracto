@regression
Feature: Filtering Every Other Peracto Admin List

  # New coverage (2026-09-18) - only Products and Orders had a dedicated
  # filtering scenario before (product-filtering.feature/
  # order-filtering.feature); every other list's filter panel was
  # completely untested. CONFIRMED (live, Carbon Admin staging,
  # 2026-09-18) the exact same generic mechanism those two files already
  # use - "Apply"/"Reset" (common.json's apply-filter-button/
  # reset-filter-button, identical everywhere), "I remember the text of
  # the first non-empty ... as ...", "I fill in the ... with the
  # remembered ..." - works unmodified for every list below, so this adds
  # Examples rows to fresh Scenario Outlines (grouped by how deep the nav
  # click sequence is, same structure as tabs-contain-expected-data.
  # feature) rather than new step definitions.
  #
  # Same "Reset first" reasoning as product-filtering.feature's own
  # Background: Peracto Admin persists an applied filter server-side per
  # logged-in user, not just this browser session, so an earlier
  # scenario's filter can still be active here - every Outline below
  # resets immediately after navigating in, before touching its own
  # filter.
  #
  # Investigated but confirmed NOT filterable at all (no filter fields
  # exist on their list page): Locations, User Groups, Tasks, Countries,
  # Templates, Elements, Element Areas, Form Submissions. Locations'
  # config even had a stale "Name" key pointing at a non-existent
  # text-filter-name testid - dead, unused, removed rather than left as a
  # trap for a future scenario.
  #
  # Row-value selectors follow products.json's own established convention
  # ("[data-testid$='-name'] a" etc.) - CONFIRMED live per list, not
  # assumed, after several genuine testid inconsistencies turned up this
  # session (Redirects' anchor uses a different-cased "-fromPath" testid
  # than its wrapping cell's "-from-path"; Product Variants' own SKU
  # column and its parent product's SKU column both end in "-sku", so the
  # variant's own value needs a ":not(...)" exclusion to avoid matching
  # the wrong column).

  Background:
    Given I am navigating the page as a "admin" user

  Scenario Outline: Filtering <nav item> by <field> narrows the list to a matching row

    When I click precisely on the "<nav item>" element
    And I click precisely on the "Reset" element
    And I remember the text of the first non-empty "<row values>" as "filter term"
    And I fill in the "<filter field>" input field with the remembered "filter term"
    And I click precisely on the "Apply" element
    Then the "<row values>" should contain the remembered "filter term"

    # Tagged so tenants with no active promotions can opt out. Andy Thornton
    # production excludes it: its Promotions list is empty under the default
    # "Active" status (confirmed live on peracto.andythornton.com,
    # 2026-09-30), and that admin is read-only so one can't be created.
    @requires-active-promotions
    Examples:
      | nav item  | field | row values    | filter field |
      | Promotions | Name | promotion name | Name filter  |

  Scenario Outline: Filtering "<parent>" > "<nav item>" by <field> narrows the list to a matching row

    When I click precisely on the "<parent>" element
    And I click precisely on the "<nav item>" element
    And I click precisely on the "Reset" element
    And I remember the text of the first non-empty "<row values>" as "filter term"
    And I fill in the "<filter field>" input field with the remembered "filter term"
    And I click precisely on the "Apply" element
    Then the "<row values>" should contain the remembered "filter term"

    Examples:
      | parent        | nav item          | field | row values           | filter field |
      | Products      | Categories        | Name  | category name         | Name filter  |
      | Products      | Product Variants  | SKU   | variant SKU           | SKU filter   |
      | Content       | Pages             | Name  | page name             | Name filter  |
      | Content       | Articles          | Heading | article heading     | Heading filter |
      | Content       | Article Categories | Name | article category name | Name filter  |
      | Users         | All Users         | Email | user email            | Email filter |

    # Split into its own Examples block so tenants with an empty Redirects
    # list can opt out. Indespension excludes it: its Redirects list is
    # empty (confirmed live on staging-peracto, 2026-09-29: API returns
    # totalItems 0 for active redirects), so there's no row to filter on.
    @requires-redirects
    Examples:
      | parent        | nav item          | field | row values           | filter field |
      | Configuration | Redirects         | From Path | redirect from path | From Path filter |

    # Split into its own Examples block so it can carry the same
    # @requires-shipping-services opt-out as editing-attributes-and-config.feature
    # (cucumber tags whole Examples blocks, not single rows). HIB excludes it:
    # its Shipping Services list is empty (confirmed live on hib-170-peracto,
    # 2026-09-24: API returns totalItems 0 for active services).
    @requires-shipping-services
    Examples:
      | parent        | nav item          | field | row values           | filter field |
      | Configuration | Shipping Services | Service Name | service name   | Service Name filter |

  Scenario Outline: Filtering "<grandparent>" > "<parent>" > "<nav item>" by <field> narrows the list to a matching row

    When I click precisely on the "<grandparent>" element
    And I click precisely on the "<parent>" element
    And I click precisely on the "<nav item>" element
    And I click precisely on the "Reset" element
    And I remember the text of the first non-empty "<row values>" as "filter term"
    And I fill in the "<filter field>" input field with the remembered "filter term"
    And I click precisely on the "Apply" element
    Then the "<row values>" should contain the remembered "filter term"

    Examples:
      | grandparent | parent     | nav item          | field | row values          | filter field |
      | Products    | Attributes | All Attributes    | Label | attribute label      | Label filter |
      | Products    | Attributes | All Attributes    | Code  | attribute code       | Code filter  |
      | Products    | Attributes | Attribute Groups  | Name  | attribute group name | Name filter  |
      | Products    | Attributes | Attribute Sets    | Name  | attribute set name   | Name filter  |
      | Content     | Forms      | All Forms         | Label | form label           | Label filter |
      | Content     | Forms      | Form Fields       | Label | form field label     | Label filter |
