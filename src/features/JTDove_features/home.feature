@regression
Feature: Home page

  # Full rewrite (2026-10-05). The previous version was copied from HIB:
  # "WE'RE ON A MISSION TO MAKE BATHROOMS BEAUTIFUL", mirror/cabinet/lighting
  # category cards - none of which exist on JT Dove. Rebuilt against the live
  # staging home page.

  Scenario: Home page shows its main content blocks
    Given I am on the "home" page
    And I wait for the page to settle
    Then the "USP bar" should be displayed
    And the "Popular Categories heading" should be displayed
    And the "Shop Categories heading" should be displayed
    And the "newsletter form" should be displayed


  Scenario Outline: Home page "<tile>" tile leads to its page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "<tile>" element, retrying until redirected to the "<page>" page
    Then the "category page title" should contain the text "<title>"
    Examples:
      | tile                | page           | title          |
      | Plywood tile        | plywood        | Plywood        |
      | Special Offers tile | special-offers | Special Offers |


  Scenario: Bathroom showrooms link opens the design appointment form
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "Bathroom showrooms link" element, retrying until redirected to the "bathroom-appointment" page
    Then the "page heading" should contain the text "Book your FREE design appointment"


  Scenario: Kitchen showrooms link lists the showrooms
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "Kitchen showrooms link" element, retrying until redirected to the "kitchen-showrooms" page
    Then the "page heading" should contain the text "Kitchen Showrooms"
    And I should see "6" "showroom headings" displayed


  # KNOWN STAGING CONTENT ISSUE (2026-10-05): one of the home page promo
  # tiles links to the PRODUCTION login page (https://www.jtdove.co.uk/login?to=/account)
  # rather than a relative /login, so a staging visitor clicking it is sent
  # to the live site. Expected to stay red until the CMS content is fixed.
  Scenario: Home page links stay on the staging site
    Given I am on the "home" page
    And I wait for the page to settle
    And the "Popular Categories heading" should be displayed
    Then the "production login link" should not be displayed
