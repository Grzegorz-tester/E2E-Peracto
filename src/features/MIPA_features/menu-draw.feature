@MIPA_regression
Feature: Menu side draw

  # Full rewrite - the previous version tested a menu item set cloned from
  # HIB ("Products", "Inspiration", "About", "Support", "News", "Careers",
  # "Find a retailer", "View brochures", "Request a Sample") that doesn't
  # exist on this site at all - confirmed live, the drawer opened by "Menu"
  # has an entirely different set of links (Brochures, Video Gallery,
  # Contact Us, Blog, Industrial Product Finder, Technical & Safety Data
  # Sheets, Flyers, Conditions Of Use), identical for guest and logged-in
  # users - no user-type-gated item like HIB's "Request a Sample" was found.

  Scenario Outline: Verify menu elements for:
  - a Logged in User
  - a Guest User
    Given I am navigating the page as a "<user type>" user
    And I click on the "Menu" icon
    Then the "Brochures draw menu item" should be displayed
    And the "Video Gallery draw menu item" should be displayed
    And the "Contact Us draw menu item" should be displayed
    And the "Blog draw menu item" should be displayed
    And the "Industrial Product Finder draw menu item" should be displayed
    Examples:
      | user type |
      | logged in |
      | guest     |


  Scenario: Navigating from the side draw menu reaches the right page
    Given I am on the "home" page
    When I click on the "Menu" icon
    And I click on the "Brochures draw menu item" element
    Then I should be redirected to the "brochures" page
