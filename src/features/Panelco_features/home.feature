@Panelco_regression
Feature: Home page


  Scenario: Verify page elements
    Given I am on the "home" page
    Then the "header logo" should be displayed
    And the "page title" should contain the text "Panelco | The Heart Of Innovation"


#  Scenario Outline: Verify:
#  - redirection to categories from the category cards
#    Given I am on the "home" page
#    When I click on the "<card>" element
#    Then I should be redirected to the "<page>" page
#    And the "category page title" should contain the text "<text>"
#    Examples:
#      | card             | page                 | text                 |
#      | Mirrors card     | bathroom-mirrors     | BATHROOM MIRRORS     |
#      | Cabinets card    | bathroom-cabinets    | BATHROOM CABINETS    |
##      | Furniture card   | bathroom-furniture   | BATHROOM FURNITURE   |
#      | Lighting card    | bathroom-lightning   | BATHROOM LIGHTING    |
#      | Accessories card | bathroom-accessories | BATHROOM ACCESSORIES |
#      | Ventilation card | bathroom-ventilation | BATHROOM VENTILATION |


  Scenario Outline: Verify:
  - redirection to feature pages from the feature cards
    Given I am on the "home" page
    When I click on the "<card>" button
    Then I should be redirected to the "<page>" page
    Examples:
      | card               | page            |
      | FIND A RETAILER    | find-a-retailer |
      | REQUEST A BROCHURE | brochure        |
      | View all posts     | news            |

