@regression
Feature: Navigation Menu

  # From KOOL-2026-08-17.json, "Storefront > Navigation Menu" (cases 419-425,
  # 433). Confirmed live at both a desktop (1280px) and mobile (390px)
  # viewport: the category links themselves (AC, Gas, Install, etc.) are
  # plain flat links with no dropdown - there is no desktop mega-menu or
  # mobile accordion. Subcategory refinement instead happens via the PLP's
  # own filter sidebar (already covered by plp-search.feature).
  #
  # CONFIRMED SITE CONTENT CHANGE (live on production, 2026-09-11):
  # production's real nav bar no longer has an "AC" top-level link at all -
  # that range now sits under "Mitsubishi Electric" branding - and "Gas"
  # now points to /category/gas-refrigerant, not /category/refrigerant.
  # Staging still shows the older "AC" -> /category/air-conditioning nav
  # (confirmed live, same date) - the two environments have genuinely
  # diverged here, not just a stale selector. Since this suite's real
  # regression target is production, the Examples below were switched to
  # "Electrical" (still present, unchanged, on both) and Gas's corrected
  # path, rather than staging's now out-of-date structure.
  #
  # CONFIRMED SITE GAP (live, 2026-08-19): the site's own markup contains a
  # full subcategory link tree (e.g. "Mitsubishi Electric M Series" nested
  # under AC) inside [data-testid='navigation-bar'], matching what Qase's
  # catalogue describes for "subcategory navigation" - but every one of these
  # links carries a bare "hidden" class with no responsive/hover/focus variant
  # that ever un-hides it, at any viewport width tested. There is no UI path
  # that reveals them, on desktop or mobile. Same class of finding as
  # Wishlists/Compare elsewhere on this site: documented in the test catalogue
  # but not actually reachable by a real user, so not covered here.

  Scenario Outline: Clicking the "<category link>" top-level category link in the navigation bar navigates to that category
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I click on the "<category link>" element
    Then the current URL should contain "<expected path>"

    # 2026-09-28: both links now go elsewhere - Electrical to the /electrical
    # landing page, Gas to /category/refrigerant - confirmed identical on
    # staging and release-2-19-0, so a site change rather than a regression.
    Examples:
      | category link            | expected path              |
      | Electrical category link | /electrical                |
      | Gas category link        | /category/refrigerant      |

  # CONFIRMED LIVE (2026-08-19): the mobile hamburger opens a completely
  # separate drawer ([data-testid='nav-tier-one'], inside a HeadlessUI
  # dialog) rather than toggling [data-testid='navigation-bar'] itself, which
  # stays "hidden" unconditionally below the "lg" breakpoint. The drawer
  # lists the exact same 9 top-level categories as the desktop bar (AC,
  # Install, Supports, Electrical, Condensate, Gas, Chemicals, Tools,
  # Refrigeration) - no subcategories, matching the gap noted above.
  #
  # CONFIRMED SITE BUG (live, 2026-08-19): clicking the drawer's own backdrop
  # closes it, but that same click then falls through to whatever category
  # link sits underneath at that screen position and navigates there too -
  # so closing the drawer this way isn't safe for a real user either. Escape
  # is used here instead, and doesn't carry that risk.
  Scenario: The mobile hamburger menu opens a category drawer that closes on Escape
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I resize the browser to a "mobile" viewport
    Then the "mobile navigation drawer" should not be displayed

    When I click on the "mobile menu button" element
    Then the "mobile navigation drawer" should be displayed

    When I press the Escape key
    Then the "mobile navigation drawer" should not be displayed

  @smoke
  Scenario: The header Account link sends a guest to Sign In and a logged-in user straight to their account
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I click on the "Account menu item" element
    Then the current URL should contain "/login"

    Given I am navigating the page as a "logged in" user
    And I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I click on the "Account menu item" element
    Then I should be redirected to the "account" page
