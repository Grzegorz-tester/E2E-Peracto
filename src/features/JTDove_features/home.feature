
Feature: Home page

  Scenario: Verify page elements
    Given I am on the "home" page
    Then the "header logo" should be displayed
    And the "page title" should contain the text "WE'RE ON A MISSION TO MAKE BATHROOMS BEAUTIFUL"


#  Scenario Outline: Verify redirection to menu elements
#    Given I am on the "home" page
#    When I click on the "<menu element>" element
#    Then I should be redirected to the "<page>" page
#    And the "page title" should contain the text "<text>"
#    Examples:
#      | menu element | page        | text        |
#      | Inspiration  | inspiration | INSPIRATION |
#      | About        | about       | ABOUT HiB   |
#      | Support      | support     | SUPPORT     |
#      | News         | news        | News        |
#      | Careers      | careers     |             |

  Scenario Outline: Verify redirection to categories from the category cards
    Given I am on the "home" page
    When I click on the "<card>" element
    Then I should be redirected to the "<page>" page
    And the "category page title" should contain the text "<text>"
    Examples:
      | card             | page                 | text                 |
      | Mirrors card     | bathroom-mirrors     | BATHROOM MIRRORS     |
      | Cabinets card    | bathroom-cabinets    | BATHROOM CABINETS    |
#      | Furniture card   | bathroom-furniture   | BATHROOM FURNITURE   |
      | Lighting card    | bathroom-lightning   | BATHROOM LIGHTING    |
      | Accessories card | bathroom-accessories | BATHROOM ACCESSORIES |
      | Ventilation card | bathroom-ventilation | BATHROOM VENTILATION |