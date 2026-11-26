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
    # 2026-11-22: Roofing/Kitchens rows removed, same category-landing template as Building Materials.
    Examples:
      | item                         | page             |
      | Building Materials menu item | category-landing |
      | Special Offers menu item     | special-offers   |


  Scenario Outline: Header "<link>" link goes to the "<page>" page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "<link>" element, retrying until redirected to the "<page>" page
    Examples:
      | link            | page       |
      # 2026-11-22: Branches row removed, covered by "Header links navigate client-side" below.
      | Sign In         | login      |
      | Basket          | basket     |
      | Contact Us link | contact-us |
      | Call your local branch link | branches |


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


  # Manual regression cases 20, 26, 27, 38 and 39 (added 2026-10-22).
  # 2026-11-22: "Clicking the logo returns to the home page" removed, covered by "Header links navigate client-side" below.
  Scenario: The site serves its favicon
    Given I am on the "home" page
    And I wait for the page to settle
    And I remember the "href" attribute of the "favicon" as "favicon path"
    Then requesting the remembered path "favicon path" should return status 200


  # The header shows no count at all for an empty basket (not "0 items" as
  # the manual case describes); a count badge appears once something is in it.
  Scenario: The header basket count appears and updates when a product is added
    Given I am on the "home" page
    And I wait for the page to settle
    Then the "basket count" should not be displayed
    When I am on the "test-product" page
    And I wait for the page to settle
    And I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed
    When I am on the "home" page
    And I wait for the page to settle
    Then the "basket count" should equal text "1"


  Scenario: VAT toggle switches PLP prices between ex. and inc. VAT
    Given I am on the "plywood" page
    And I wait for the page to settle
    And I remember the text of "PLP first product card price" as "ex vat price"
    Then the "PLP first product card" should contain the text "Ex."
    When I click on the "VAT toggle" element
    Then the "PLP first product card price" text should not equal the remembered "ex vat price"
    And the "PLP first product card" should contain the text "Inc."
    When I click on the "VAT toggle" element
    Then the "PLP first product card price" text should equal the remembered "ex vat price"


  # BEN-394 (Benchmarx Next.js 15, added 2026-11-22): header links did a full
  # document reload instead of client-side navigation. Confirmed 2026-11-22
  # that staging soft-navigates once hydrated.
  Scenario: Header links navigate client-side without a full page reload
    Given I am on the "home" page
    And I wait for the page to settle
    When I mark the current document so a full page reload can be detected
    And I click on the "Branches" link
    Then I should eventually be redirected to the "branches" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "header logo" link
    Then I should eventually be redirected to the "home" page
    And the page should not have been fully reloaded since it was marked

