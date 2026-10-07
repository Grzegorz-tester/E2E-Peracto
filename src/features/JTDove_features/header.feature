@regression
Feature: Header functionality

  # Full rewrite (2026-10-05). The old version checked for top-level menu
  # items that don't exist on JT Dove (Bricks & Blocks, Tools & Workwear,
  # Clearance, "Bathrooms & Kitchens") and a "Sign In" icon. Search moved to
  # search-drawer.feature.

  Scenario: Main navigation lists the real top-level categories
    Given I am on the "home" page
    And I wait for the page to settle
    Then the "1st" "navigation items" should contain the text "Building Materials"
    And the "2nd" "navigation items" should contain the text "Timber & Sheet"
    And the "3rd" "navigation items" should contain the text "Bathrooms"
    And the "4th" "navigation items" should contain the text "Landscaping & Gardening"
    And the "5th" "navigation items" should contain the text "Roofing"
    And the "6th" "navigation items" should contain the text "Workwear"
    And the "7th" "navigation items" should contain the text "Painting & Decorating"
    And the "8th" "navigation items" should contain the text "Doors, Flooring & Joinery"
    And the "9th" "navigation items" should contain the text "Plumbing & Heating"
    And the "10th" "navigation items" should contain the text "Kitchens"
    And the "11th" "navigation items" should contain the text "Special Offers"


  Scenario Outline: "<item>" menu item opens its landing page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "<item>" element, retrying until redirected to the "<page>" page
    Then the "category page title" should be displayed
    Examples:
      | item                         | page             |
      | Building Materials menu item | category-landing |
      | Roofing menu item            | category-landing |
      | Kitchens menu item           | category-landing |
      | Special Offers menu item     | special-offers   |


  Scenario Outline: Header "<link>" link goes to the "<page>" page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "<link>" element, retrying until redirected to the "<page>" page
    Examples:
      | link            | page       |
      | Sign In         | login      |
      | Branches        | branches   |
      | Basket          | basket     |
      | Contact Us link | contact-us |


  Scenario Outline: "<link>" redirects a guest to the login page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "<link>" element, retrying until redirected to the "login" page
    Then the current URL should contain "<return path>"
    Examples:
      | link     | return path            |
          | My Dove  | to=%2Faccount             |
      | My Lists | to=%2Faccount%2Fwishlists |


  # The VAT switch flips every price between ex. and inc. VAT. Confirmed live
  # 2026-10-05 on the test product: £56.98 EX. VAT <-> £68.38 INC. VAT
  # (56.98 x 1.2 = 68.376, rounded). It's a site-wide preference, so the
  # scenario switches it back at the end.
  Scenario: VAT toggle switches PDP prices between ex. and inc. VAT
    Given I am on the "test-product" page
    And I wait for the page to settle
    Then the "product price" should contain the text "£56.98"
    And the "PDP tax message" should contain the text "Ex"
    When I click on the "VAT toggle" element
    Then the "product price" should contain the text "£68.38"
    And the "PDP tax message" should contain the text "Inc"
    When I click on the "VAT toggle" element
    Then the "product price" should contain the text "£56.98"
