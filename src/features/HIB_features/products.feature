@regression
Feature: Products page functionality


  Scenario Outline: Verify the Products hub page lists every category and links to the right page
    Given I am on the "products" page
    And I dismiss the newsletter popup if present
    Then the "<card>" should be displayed
    When I click on the "<card>" element
    Then I should be redirected to the "<category>" page
    Examples:
      | card             | category             |
      | Mirrors card     | bathroom-mirrors     |
      | Cabinets card    | bathroom-cabinets    |
      | Furniture card   | bathroom-furniture   |
      | Basins card      | bathroom-basins      |
      | Accessories card | bathroom-accessories |
      | Ventilation card | bathroom-ventilation |
      | Lighting card    | bathroom-lightning   |
      | Brassware card   | bathroom-brassware   |


  Scenario: Filtering products, then clearing the filter with "Clear all"
    Given I am on the "bathroom-cabinets" page
    And I dismiss the newsletter popup if present
    When I remember the number of "product card" elements as "unfiltered count"
    And I click on the "Filter" element
    And I click on the "Apex checkbox" element
    Then the current URL should contain "refinementList"
    And the number of "product card" elements should be fewer than the remembered "unfiltered count"
    When I click on the "Clear all" element
    Then the number of "product card" elements should equal the remembered "unfiltered count"


  Scenario: Sorting products
    Given I am on the "bathroom-mirrors" page
    And I dismiss the newsletter popup if present
    When I remember the text of "first product name" as "name before sort"
    And I click on the "Sort By" dropdown
    And I click on the "A-Z" element
    Then the "first product name" text should not equal the remembered "name before sort"
