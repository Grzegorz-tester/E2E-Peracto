@Panelco_regression
Feature: Menu side draw


  Scenario Outline: Verify menu elements for:
  - a Logged in User
  - a Guest User
    Given I am navigating the page as a "<user type>" user
    And I click on the "Menu" icon
    Then the "Products draw menu item" should be displayed
    And the "Inspiration draw menu item" should be displayed
    And the "About draw menu item" should be displayed
    And the "Support draw menu item" should be displayed
    And the "News draw menu item" should be displayed
    And the "Careers draw menu item" should be displayed
    And the "Find a retailer menu item" should be displayed
    And the "View brochures menu item" should be displayed
    And the "Request a Sample menu item" should <presence> be displayed
    Examples:
      | user type | presence |
      | logged in | not      |
      | guest     |          |


