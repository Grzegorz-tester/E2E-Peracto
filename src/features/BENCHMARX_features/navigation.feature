@regression
Feature: Navigation - menu drawer, mobile menu, breadcrumbs, history and client-side routing

  # BEN-379 (Next.js 15 upgrade) NAV-02 to NAV-06. Built 2026-11-11 from a
  # live inspection of staging. The desktop "Menu" button opens a Radix
  # sheet (role=dialog) of tiers: a top tier (Kitchens, Accessories and
  # appliances, Joinery, Ideas and inspiration, Help and advice, Read our
  # blog), each drilling into a sub-tier with a Back button. "Help and
  # advice" goes two levels deep (Choosing your kitchen > Book a design
  # consultation, Kitchen visualiser, ...). On mobile the same sheet opens
  # from the brand bar's hamburger instead.

  # NAV-02
  Scenario: The menu drawer opens, drills into submenus, goes back and closes
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "menu button" button
    Then the "menu drawer" should be displayed
    And the "menu Kitchens" should be displayed
    And the "menu Help and advice" should be displayed
    When I click on the "menu Help and advice" element
    Then the "menu Choosing your kitchen" should be displayed
    And the "menu back button" should be displayed
    When I click on the "menu Choosing your kitchen" element
    Then the "menu Book a design consultation" should be displayed
    And the "menu Kitchen visualiser" should be displayed
    When I click on the "menu back button" button
    Then the "menu Choosing your kitchen" should be displayed
    When I click on the "menu back button" button
    Then the "menu Kitchens" should be displayed
    And the "menu back button" should not be displayed
    When I click on the "menu close button" button
    Then the "menu drawer" should not be displayed

  # NAV-02: every link reachable in the drawer's Kitchens tier opens a real page.
  Scenario: The menu drawer's Kitchens submenu links open real pages
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "menu button" button
    And I click on the "menu Kitchens" element
    Then the "menu View All" should be displayed
    And the "menu Shop by range" should be displayed
    And all "menu drawer link hrefs" links should resolve without an error
    When I click on the "menu View All" link
    Then I should be redirected to the "all-kitchens" page
    And the "product cards" should be displayed

  # Tiers with children (Kitchens, Accessories and appliances, ...) drill in
  # rather than navigate; their landing page is the sub-tier's "View All".
  Scenario: The menu drawer's Accessories and appliances View All opens its landing page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "menu button" button
    And I click on the "menu Accessories and appliances" element
    And I click on the "menu View All" link
    Then I should be redirected to the "accessories-and-appliances" page

  Scenario: The menu drawer's Read our blog link opens the blog
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "menu button" button
    And I click on the "menu Read our blog" element
    Then I should be redirected to the "blog" page

  # NAV-03: on a phone the hamburger opens the same drawer and locks page
  # scrolling behind it.
  Scenario: The mobile menu opens, locks page scrolling, drills down and closes
    Given I am on the "home" page
    And I resize the browser to a "mobile" viewport
    And I wait for the page to settle
    Then page scrolling should not be locked
    When I click on the "mobile menu button" button
    Then the "menu drawer" should be displayed
    And page scrolling should be locked
    When I click on the "menu Help and advice" element
    Then the "menu Choosing your kitchen" should be displayed
    When I click on the "menu back button" button
    And I click on the "menu Kitchens" element
    And I click on the "menu View All" link
    Then I should be redirected to the "all-kitchens" page
    And page scrolling should not be locked

  # NAV-04
  Scenario Outline: The <page> page shows a breadcrumb whose links resolve
    Given I navigate directly to the path "<path>"
    Then the "breadcrumb" should be displayed
    And the "breadcrumb" should contain the text "<trail>"
    And all "breadcrumb links" links should resolve without an error

    Examples:
      | page        | path                                     | trail      |
      | listing     | /kitchen-ranges/all-kitchens             | Home       |
      | product     | /kitchens/nordica-blue-true-handleless   | Home       |
      | article     | /article/new-benchmarx-design-bude-range | Blog       |
      | branch      | /branches/leeds                          | Branches   |
      | content     | /contact-us                              | Home       |
      | subcategory | /accessories                             | Accessories and appliances |

  # NAV-05. Staging keeps neither filters nor page number in the URL
  # (Algolia routing is off; a reload after filtering shows all 137 again,
  # confirmed live 2026-11-11), so this checks Back returns to a working
  # listing with the same count it left.
  Scenario: Pressing Back from a product returns to the kitchen listing as staging does
    Given I am on the "all-kitchens" page
    And I wait for the page to settle
    When I remember the text of "hit count" as "unfiltered count"
    And I click on the "first product card" link
    Then I should be redirected to the "pdp" page
    When I go back in the browser history
    Then I should be redirected to the "all-kitchens" page
    And the "product cards" should be displayed
    And the "hit count" text should equal the remembered "unfiltered count"

  # NAV-06: moving between pages via links is a client-side (soft)
  # navigation, not a full document reload.
  Scenario: Header and listing links navigate client-side without a full page reload
    Given I am on the "home" page
    And I wait for the page to settle
    When I mark the current document so a full page reload can be detected
    And I click on the "Find a branch" link
    Then I should be redirected to the "branches" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "header logo" link
    Then I should be redirected to the "home" page
    And the page should not have been fully reloaded since it was marked
