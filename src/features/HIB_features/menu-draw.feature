@regression
Feature: Menu side draw


  Scenario Outline: Verify menu elements for a "<user type>" user
    Given I am navigating the page as a "<user type>" user
    And I dismiss the newsletter popup if present
    # Retrying: confirmed on staging (2026-10-14) that straight after login the
    # first Menu click can land before the header hydrates, so the drawer never
    # opens (failed on attempt 1, passed on the cucumber retry).
    And I click on the "Menu" icon, retrying until the "Products draw menu item" appears
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


