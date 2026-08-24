@regression
Feature: Menu side draw

  # Previously tested a menu item set cloned from HIB ("Inspiration",
  # "Careers", "News", "Request a Sample", etc.) that doesn't exist on this
  # site at all - confirmed live, the drawer opened by "Menu" has exactly
  # seven links: Trailers, Trailer Parts, Trailer Hire, Towbars, Offers,
  # Services, Used Trailers, identical for guest and logged-in users (no
  # user-type-gated item like HIB's "Request a Sample" was found).

  Scenario Outline: Verify menu elements for:
  - a Logged in User
  - a Guest User
    # Logging in lands on /account, a dashboard layout with no storefront
    # hamburger menu at all (confirmed live) - unlike guest, who lands
    # straight on the storefront homepage. Navigate back to "home"
    # explicitly so both rows reach the same drawer regardless of where
    # the "logged in"/"guest" step itself lands.
    Given I am navigating the page as a "<user type>" user
    And I am on the "home" page
    And I click on the "Menu" icon
    Then the "Trailers" should be displayed
    And the "Trailer Parts" should be displayed
    And the "Trailer Hire" should be displayed
    And the "Towbars" should be displayed
    And the "Offers" should be displayed
    And the "Services" should be displayed
    And the "Used Trailers" should be displayed
    Examples:
      | user type |
      | logged in |
      | guest     |


  Scenario: Navigating from the side draw menu reaches the right page
    Given I am on the "home" page
    When I click on the "Menu" icon
    And I click on the "Towbars" element
    Then I should be redirected to the "towbars" page
