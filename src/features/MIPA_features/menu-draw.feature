@regression
Feature: Menu side draw

  # Full rewrite - the previous version tested a menu item set cloned from
  # HIB ("Products", "Inspiration", "About", "Support", "News", "Careers",
  # "Find a retailer", "View brochures", "Request a Sample") that doesn't
  # exist on this site at all - confirmed live, the drawer opened by "Menu"
  # has an entirely different set of links (Brochures, Video Gallery,
  # Contact Us, Blog, Industrial Product Finder, Technical & Safety Data
  # Sheets, Flyers, Conditions Of Use), identical for guest and logged-in
  # users - no user-type-gated item like HIB's "Request a Sample" was found.
  #
  # 2026-09-25: the drawer was reorganised (identical on feature-next-15 and
  # staging): Video Gallery, Contact Us, Technical & Safety Data Sheets and
  # Conditions Of Use were dropped from it (still linked from the footer),
  # and Help & Advice (the new /contact-us page) was added.

  Scenario Outline: Verify menu elements for a "<user type>" user
    Given I am navigating the page as a "<user type>" user
    And I click on the "Menu" icon
    Then the "Brochures draw menu item" should be displayed
    And the "Help & Advice draw menu item" should be displayed
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
