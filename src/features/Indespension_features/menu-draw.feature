@regression
Feature: Menu side draw

  # Previously tested a menu item set cloned from HIB ("Inspiration",
  # "Careers", "News", "Request a Sample", etc.) that doesn't exist on this
  # site at all - confirmed live, the drawer opened by "Menu" has exactly
  # seven links: Trailers, Trailer Parts, Trailer Hire, Towbars, Offers,
  # Services, Used Trailers, identical for guest and logged-in users (no
  # user-type-gated item like HIB's "Request a Sample" was found).

  Scenario Outline: Verify menu elements for a "<user type>" user
    # Logging in lands on /account, a dashboard layout with no storefront
    # hamburger menu at all (confirmed live) - unlike guest, who lands
    # straight on the storefront homepage. Navigate back to "home"
    # explicitly so both rows reach the same drawer regardless of where
    # the "logged in"/"guest" step itself lands.
    Given I am navigating the page as a "<user type>" user
    And I am on the "home" page
    # Retry the Menu click until the drawer is really open (2026-09-29):
    # on production an early click is sometimes swallowed before the header
    # hydrates, leaving no drawer at all ("no element matched" for every
    # drawer link, confirmed in the first production runs).
    And I click on the "Menu" element, retrying until the "open menu drawer" is displayed
    Then the "Trailers" should be displayed
    And the "Trailer Parts" should be displayed
    And the "Trailer Hire" should be displayed
    And the "Towbars" should be displayed
    And the "Used Trailers" should be displayed
    Examples:
      | user type |
      | logged in |
      | guest     |


  # 2026-09-29: items that only exist on one environment (confirmed live -
  # staging has Offers + Services, production has News instead). Before
  # the drawer-scoped selectors, "Offers"/"Services" silently passed on
  # production by matching whatever header link sat at that index.
  Scenario Outline: The environment-specific "<menu element>" item is in the menu drawer
    Given I am on the "home" page
    # Retry the Menu click until the drawer is really open (2026-09-29):
    # on production an early click is sometimes swallowed before the header
    # hydrates, leaving no drawer at all ("no element matched" for every
    # drawer link, confirmed in the first production runs).
    And I click on the "Menu" element, retrying until the "open menu drawer" is displayed
    Then the "<menu element>" should be displayed

    @not-on-production
    Examples:
      | menu element |
      | Offers       |
      | Services     |

    @production-only
    Examples:
      | menu element |
      | News         |


  Scenario: Navigating from the side draw menu reaches the right page
    Given I am on the "home" page
    # Retry the Menu click until the drawer is really open (2026-09-29):
    # on production an early click is sometimes swallowed before the header
    # hydrates, leaving no drawer at all ("no element matched" for every
    # drawer link, confirmed in the first production runs).
    When I click on the "Menu" element, retrying until the "open menu drawer" is displayed
    And I click on the "Towbars" element
    Then I should be redirected to the "towbars" page
