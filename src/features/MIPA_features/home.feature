@MIPA_regression
Feature: Home page

  # Full rewrite - the previous version asserted HIB's bathroom-fixtures
  # content (page title "WE'RE ON A MISSION TO MAKE BATHROOMS BEAUTIFUL",
  # category cards for Mirrors/Cabinets/Furniture/Lighting/Accessories/
  # Ventilation, feature cards "FIND A RETAILER"/"REQUEST A BROCHURE").
  # None of it exists on MIPA - confirmed live, staging.mipa-paints.pub is
  # a trade paint/coatings supplier with an entirely different homepage.

  Scenario: Verify page elements
    Given I am on the "home" page
    Then the "header logo" should be displayed
    And the "page title" should contain the text "The trusted choice for professional automotive, industrial and defence coatings in the UK and Ireland"

  Scenario Outline: Verify:
  - redirection to categories from the "Shop by Category" cards
    Given I am on the "home" page
    When I click on the "<card>" element
    Then I should be redirected to the "<page>" page
    And the "category page title" should contain the text "<text>"
    Examples:
      | card                | page       | text                  |
      | Refinishing card    | refinishing | Mipa Refinishing     |
      | Industrial card     | industrial  | Mipa ProMix Industrial |
      | Aerosols card       | aerosols    | Aerosols             |
      | MP Products card    | mp-products | MP Products          |


  Scenario: Verify:
  - redirection to the blog from the "View Articles" link
    Given I am on the "home" page
    When I click on the "View Articles" element
    Then I should be redirected to the "blog" page
